//
//  DownloadManager.swift
//  Core
//
//  Created by  Stepanok Ivan on 08.03.2023.
//

import Alamofire
import SwiftUI
import Combine

public enum DownloadState: String {
    case waiting
    case inProgress
    case finished

    public var order: Int {
        switch self {
        case .inProgress:
            1
        case .waiting:
            2
        case .finished:
            3
        }
    }
}

public enum DownloadType: String {
    case video
}

public struct DownloadDataTask: Identifiable, Hashable {
    public let id: String
    public let courseId: String
    public let blockId: String
    public let userId: Int
    public let url: String
    public let fileName: String
    public let displayName: String
    public var progress: Double
    public let resumeData: Data?
    public var state: DownloadState
    public let type: DownloadType
    public let fileSize: Int

    public var fileSizeInMb: Double {
        Double(fileSize) / 1024.0 / 1024.0
    }

    public var fileSizeInMbText: String {
        String(format: "%.2fMB", fileSizeInMb)
    }

    public init(
        id: String,
        blockId: String,
        courseId: String,
        userId: Int,
        url: String,
        fileName: String,
        displayName: String,
        progress: Double,
        resumeData: Data?,
        state: DownloadState,
        type: DownloadType,
        fileSize: Int
    ) {
        self.id = id
        self.courseId = courseId
        self.blockId = blockId
        self.userId = userId
        self.url = url
        self.fileName = fileName
        self.displayName = displayName
        self.progress = progress
        self.resumeData = resumeData
        self.state = state
        self.type = type
        self.fileSize = fileSize
    }

    public init(sourse: CDDownloadData) {
        self.id = sourse.id ?? ""
        self.blockId = sourse.blockId ?? ""
        self.courseId = sourse.courseId ?? ""
        self.userId = Int(sourse.userId)
        self.url = sourse.url ?? ""
        self.fileName = sourse.fileName ?? ""
        self.displayName = sourse.displayName ?? ""
        self.progress = sourse.progress
        self.resumeData = sourse.resumeData
        self.state = DownloadState(rawValue: sourse.state ?? "") ?? .waiting
        self.type = DownloadType(rawValue: sourse.type ?? "") ?? .video
        self.fileSize = Int(sourse.fileSize)
    }
    
    public init?(block: CourseBlock, userId: Int, downloadQuality: DownloadQuality) {
        guard let video = block.encodedVideo?.video(downloadQuality: downloadQuality),
              let url = video.url,
              let fileExtension = URL(string: url)?.pathExtension
        else { return nil }
        let fileName = "\(block.id).\(fileExtension)"
        
        let downloadDataId = "\(userId)_\(block.id)"
        self.id = downloadDataId
        self.blockId = block.id
        self.userId = userId
        self.courseId = block.courseId
        self.url = url
        self.fileName = fileName
        self.displayName = block.displayName
        self.progress = Double.zero
        self.resumeData = nil
        self.state = .waiting
        self.type = .video
        self.fileSize = video.fileSize ?? 0
    }
}

public class NoWiFiError: LocalizedError {
    public init() {}
}

//sourcery: AutoMockable
public protocol DownloadManagerProtocol {
    var currentDownloadTask: DownloadDataTask? { get }
    func publisher() -> AnyPublisher<Int, Never>
    func eventPublisher() -> AnyPublisher<DownloadManagerEvent, Never>

    func addToDownloadQueue(blocks: [CourseBlock]) async throws

    func getDownloadTasks() async -> [DownloadDataTask]
    func getDownloadTasksForCourse(_ courseId: String) async -> [DownloadDataTask]

    func cancelDownloading(courseId: String, blocks: [CourseBlock]) async throws
    func cancelDownloading(task: DownloadDataTask) async throws
    func cancelDownloading(courseId: String) async throws
    func cancelAllDownloading() async throws

    func deleteAll() async

    func fileUrl(for blockId: String) -> URL?

    func resumeDownloading() async throws
    func isLargeVideosSize(blocks: [CourseBlock]) -> Bool
    
    func removeAppSupportDirectoryUnusedContent()
    func delete(blocks: [CourseBlock], courseId: String) async
}

public enum DownloadManagerEvent {
    case added
    case started(DownloadDataTask)
    case progress(Double, DownloadDataTask)
    case paused(DownloadDataTask)
    case canceled([DownloadDataTask])
    case courseCanceled(String)
    case allCanceled
    case finished(DownloadDataTask)
    case deletedFile([String])
    case clearedAll
}

enum DownloadManagerState {
    case idle
    case downloading
    case paused
}

public class DownloadManager: DownloadManagerProtocol {
    // MARK: - Properties

    public var currentDownloadTask: DownloadDataTask?
    private let persistence: CorePersistenceProtocol
    private let appStorage: CoreStorage
    private let connectivity: ConnectivityProtocol
    private var downloadRequest: DownloadRequest?
    private var currentDownloadEventPublisher: PassthroughSubject<DownloadManagerEvent, Never> = .init()
    private let backgroundTaskProvider = BackgroundTaskProvider()
    private var cancellables = Set<AnyCancellable>()

    private var downloadQuality: DownloadQuality {
        appStorage.userSettings?.downloadQuality ?? .auto
    }

    private var userId: Int {
        appStorage.user?.id ?? 0
    }
    
    private var queue: [DownloadDataTask] = [] {
        didSet {
            queuePublisher.send(0)
        }
    }
    private var queuePublisher: PassthroughSubject<Int, Never> = .init()
    private var state: DownloadManagerState = .idle
    // MARK: - Init

    public init(
        persistence: CorePersistenceProtocol,
        appStorage: CoreStorage,
        connectivity: ConnectivityProtocol
    ) {
        self.persistence = persistence
        if let userId = appStorage.user?.id {
            self.persistence.set(userId: userId)
        }
        self.appStorage = appStorage
        self.connectivity = connectivity
        connectivity.internetReachableSubject
            .sink {[weak self] state in
                guard let self else { return }
                Task {
                    switch state {
                    case .notReachable:
                        await self.waitingAll()
                    case .reachable:
                        try? await self.resumeDownloading()
                    case .none:
                        return
                    }
                }
            }
            .store(in: &cancellables)
        self.backgroundTask()
        Task {
            try? await self.resumeDownloading()
        }
    }

    // MARK: - Publishers

    public func publisher() -> AnyPublisher<Int, Never> {
        queuePublisher
            .share()
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    public func eventPublisher() -> AnyPublisher<DownloadManagerEvent, Never> {
        currentDownloadEventPublisher
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    // MARK: - Intents

    public func isLargeVideosSize(blocks: [CourseBlock]) -> Bool {
        var totalSize: Int = 0
        blocks.forEach { block in
            totalSize += block.encodedVideo?.video(downloadQuality: downloadQuality)?.fileSize ?? 0
        }
        return totalSize / (1024 * 1024 * 1024) > 1
    }

    public func getDownloadTasks() async -> [DownloadDataTask] {
        if queue.isEmpty {
            queue =  await persistence.getDownloadDataTasks()
        }
        return queue
    }

    public func getDownloadTasksForCourse(_ courseId: String) async -> [DownloadDataTask] {
        if queue.isEmpty {
            await persistence.getDownloadDataTasksForCourse(courseId)
        } else {
            queue.filter({$0.courseId == courseId})
        }
    }

    public func addToDownloadQueue(blocks: [CourseBlock]) async throws {
        if userCanDownload() {
            let newTasks = blocks.compactMap {
                DownloadDataTask(
                    block: $0,
                    userId: userId,
                    downloadQuality: downloadQuality
                )
            }

            for task in newTasks where queue.first(where: { $0.id == task.id }) == nil {
                queue.append(task)
            }

            await persistence.addToDownloadQueue(
                blocks: blocks,
                downloadQuality: downloadQuality
            )
            currentDownloadEventPublisher.send(.added)
            try await newDownload()
        } else {
            throw NoWiFiError()
        }
    }

    public func resumeDownloading() async throws {
        guard state != .downloading && connectivity.isInternetAvaliable else { return }
        state = .idle
        if queue.isEmpty {
            queue = await persistence.getDownloadDataTasks()
        }
        try await newDownload()
    }

    private func cancelCurrentTask() {
        downloadRequest?.cancel()
        currentDownloadTask = nil
    }
    public func cancelDownloading(courseId: String, blocks: [CourseBlock]) async throws {
        if blocks.contains(where: { $0.id == currentDownloadTask?.blockId }) {
            cancelCurrentTask()
        }
        await delete(blocks: blocks, courseId: courseId)
        try await newDownload()
    }

    public func cancelDownloading(task: DownloadDataTask) async throws {
        if task.id == currentDownloadTask?.id {
            cancelCurrentTask()
        }

        await delete(tasks: [task])
        try await newDownload()
    }

    public func cancelDownloading(courseId: String) async throws {
        if currentDownloadTask?.courseId == courseId {
            cancelCurrentTask()
        }

        let tasks = await getDownloadTasksForCourse(courseId)
        await delete(tasks: tasks)
        currentDownloadEventPublisher.send(.courseCanceled(courseId))
        try await newDownload()
    }

    public func cancelAllDownloading() async throws {
        cancelCurrentTask()

        let tasks = await getDownloadTasks().filter { $0.state != .finished }
        await delete(tasks: tasks)
        currentDownloadEventPublisher.send(.allCanceled)
        try await newDownload()
    }

    public func delete(blocks: [CourseBlock], courseId: String) async {
        let tasks = await getDownloadTasksForCourse(courseId)
        let tasksForDelete = tasks.filter {  task in
            blocks.first(where: { $0.id == task.blockId }) != nil
        }
        await delete(tasks: tasksForDelete)
    }

    public func deleteAll() async {
        let downloadsData = await getDownloadTasks()
        await delete(tasks: downloadsData)
        currentDownloadEventPublisher.send(.clearedAll)
    }

    private func downloadTask(for blockId: String) -> DownloadDataTask? {
        if queue.isEmpty {
            return persistence.downloadDataTask(for: blockId)
        }
        return queue.first(where: {$0.blockId == blockId})
    }
    
    public func fileUrl(for blockId: String) -> URL? {
        guard let data = downloadTask(for: blockId),
              data.url.count > 0,
              data.state == .finished
        else {
            return nil
        }
        let path = videosFolderUrl
        let fileName = data.fileName
        return path?.appendingPathComponent(fileName)
    }

    // MARK: - Private Intents

    private func newDownload() async throws {
        guard state != .paused else { return }
        guard userCanDownload() else {
            throw NoWiFiError()
        }
        guard downloadRequest?.state != .resumed else { return }
        guard let downloadTask = queue.first(where: {$0.state != .finished}) else {
            downloadRequest = nil
            currentDownloadTask = nil
            return
        }
        try await downloadFileWithProgress(downloadTask)
    }

    private func userCanDownload() -> Bool {
        if appStorage.userSettings?.wifiOnly ?? true {
            if !connectivity.isMobileData {
                return true
            } else {
                return false
            }
        } else {
            return true
        }
    }

    private func downloadFileWithProgress(_ download: DownloadDataTask) async throws {
        guard state != .paused else { return }
        guard let url = URL(string: download.url), let folderURL = self.videosFolderUrl else {
            await delete(tasks: [download])
            try await newDownload()
            return
        }

        currentDownloadEventPublisher.send(.started(download))

        if let index = queue.firstIndex(where: {$0.id == download.id}) {
            queue[index].state = .inProgress
        }
        
        persistence.updateDownloadState(
            id: download.id,
            state: .inProgress,
            resumeData: download.resumeData
        )
        currentDownloadTask = download
        currentDownloadTask?.state = .inProgress
        let destination: DownloadRequest.Destination = { _, _ in
            let file = folderURL.appendingPathComponent(download.fileName)
            return (file, [.createIntermediateDirectories, .removePreviousFile])
        }
        if let resumeData = download.resumeData {
            downloadRequest = AF.download(resumingWith: resumeData, to: destination)
        } else {
            downloadRequest = AF.download(url, to: destination)
        }

        downloadRequest?.downloadProgress { [weak self]  prog in
            guard let self else { return }
            let fractionCompleted = prog.fractionCompleted
            self.currentDownloadTask?.progress = fractionCompleted
            self.currentDownloadEventPublisher.send(.progress(fractionCompleted, download))
            let completed = Double(fractionCompleted * 100)
            debugLog(">>>>> Downloading", download.url, completed, "%")
        }

        downloadRequest?.responseData { [weak self] response in
            guard let self else { return }
            var state: DownloadState = .finished
            if let error = response.error, error.isInternetError {
                state = .waiting
            }
            self.persistence.updateDownloadState(
                id: download.id,
                state: state,
                resumeData: nil
            )
            if let index = queue.firstIndex(where: {$0.id == download.id}) {
                queue[index].state = state
            }
            self.currentDownloadTask?.state = state
            
            if state != .waiting {
                self.currentDownloadEventPublisher.send(.finished(download))
                Task {
                    try? await self.newDownload()
                }
            } else {
                self.currentDownloadEventPublisher.send(.paused(download))
            }
        }
        state = .downloading
    }

    private func waitingAll() async {
        guard state != .paused else { return }
        downloadRequest?.suspend()

        for i in 0 ..< queue.count where queue[i].state == .inProgress {
            queue[i].state = .waiting

            self.persistence.updateDownloadState(
                id: queue[i].id,
                state: .waiting,
                resumeData: nil
            )
        }
        self.currentDownloadEventPublisher.send(.added)
        state = .paused
    }

    private func delete(tasks: [DownloadDataTask]) async {
        let ids = tasks.map { $0.id }
        let names = tasks.map { $0.fileName }

        await deleteTasks(with: ids, and: names)
        currentDownloadEventPublisher.send(.deletedFile(tasks.map({$0.blockId})))
    }
    
    private func deleteTasks(with ids: [String], and names: [String]) async {
        queue.removeAll(where: {ids.contains($0.id)})
        removeFiles(names: names)
        await persistence.deleteDownloadDataTasks(ids: ids)
    }
    
    private func removeFiles(names: [String]) {
        guard let folderURL = videosFolderUrl else { return }
        for name in names {
            let fileURL = folderURL.appendingPathComponent(name)
            if FileManager.default.fileExists(atPath: fileURL.path) {
                do {
                    try FileManager.default.removeItem(at: fileURL)
                } catch {
                    debugLog("Error deleting file: \(error.localizedDescription)")
                }
            }
        }
    }

    private func backgroundTask() {
        backgroundTaskProvider.eventPublisher()
            .sink { [weak self] state in
                guard let self else { return }
                Task {
                    switch state {
                    case.didBecomeActive: try? await self.resumeDownloading()
                    case .didEnterBackground: await self.waitingAll()
                    }
                }
            }
            .store(in: &cancellables)
    }

    lazy var videosFolderUrl: URL? = {
        let documentDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let directoryURL = documentDirectoryURL.appendingPathComponent(folderPathComponent, isDirectory: true)

        if FileManager.default.fileExists(atPath: directoryURL.path) {
            return URL(fileURLWithPath: directoryURL.path)
        } else {
            do {
                try FileManager.default.createDirectory(
                    at: directoryURL,
                    withIntermediateDirectories: true,
                    attributes: nil
                )
                return URL(fileURLWithPath: directoryURL.path)
            } catch {
                debugLog(error.localizedDescription)
                return nil
            }
        }
    }()

    private var folderPathComponent: String {
        if let id = appStorage.user?.id {
            return "\(id)_Files"
        }
        return "Files"
    }

    private func saveFile(fileName: String, data: Data, folderURL: URL) {
        let fileURL = folderURL.appendingPathComponent(fileName)
        do {
            try data.write(to: fileURL)
        } catch {
            debugLog("SaveFile Error", error.localizedDescription)
        }
    }
    
    public func removeAppSupportDirectoryUnusedContent() {
        deleteMD5HashedFolders()
    }
    
    private func getApplicationSupportDirectory() -> URL? {
        let fileManager = FileManager.default
        do {
            let appSupportDirectory = try fileManager.url(
                for: .applicationSupportDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            )
            return appSupportDirectory
        } catch {
            debugPrint("Error getting Application Support Directory: \(error)")
            return nil
        }
    }
    
    private func isMD5Hash(_ folderName: String) -> Bool {
        let md5Regex = "^[a-fA-F0-9]{32}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", md5Regex)
        return predicate.evaluate(with: folderName)
    }
    
    private func deleteMD5HashedFolders() {
        guard let appSupportDirectory = getApplicationSupportDirectory() else {
            return
        }
        
        let fileManager = FileManager.default
        do {
            let folderContents = try fileManager.contentsOfDirectory(
                at: appSupportDirectory,
                includingPropertiesForKeys: nil,
                options: []
            )
            for folderURL in folderContents {
                let folderName = folderURL.lastPathComponent
                if isMD5Hash(folderName) {
                    do {
                        try fileManager.removeItem(at: folderURL)
                        debugPrint("Deleted folder: \(folderName)")
                    } catch {
                        debugPrint("Error deleting folder \(folderName): \(error)")
                    }
                }
            }
        } catch {
            debugPrint("Error reading contents of Application Support directory: \(error)")
        }
    }
}

@available(iOSApplicationExtension, unavailable)
public final class BackgroundTaskProvider {

    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    private var currentEventPublisher: PassthroughSubject<Events, Never> = .init()

    public enum Events {
        case didBecomeActive
        case didEnterBackground
    }

    public func eventPublisher() -> AnyPublisher<Events, Never> {
        currentEventPublisher
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    // MARK: - Init -

    deinit {
        NotificationCenter.default.removeObserver(
            self,
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
        NotificationCenter.default.removeObserver(
            self,
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }

    public init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didEnterBackgroundNotification),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didBecomeActiveNotification),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }

    @objc
    func didEnterBackgroundNotification() {
        registerBackgroundTask()
        currentEventPublisher.send(.didEnterBackground)
    }

    @objc
    func didBecomeActiveNotification() {
        endBackgroundTaskIfActive()
        currentEventPublisher.send(.didBecomeActive)
    }

    // MARK: - Background Task -

    private func registerBackgroundTask() {
        backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            debugLog("iOS has signaled time has expired")
            self?.endBackgroundTaskIfActive()
        }
    }

    private func endBackgroundTaskIfActive() {
        let isBackgroundTaskActive = backgroundTask != .invalid
        if isBackgroundTaskActive {
            debugLog("Background task ended.")
            UIApplication.shared.endBackgroundTask(backgroundTask)
            backgroundTask = .invalid
        }
    }
}

// Mark - For testing and SwiftUI preview
// swiftlint:disable file_length
#if DEBUG
public class DownloadManagerMock: DownloadManagerProtocol {
    public func delete(blocks: [CourseBlock], courseId: String) async {
        
    }
    
    public init() {
        
    }

    public var currentDownloadTask: DownloadDataTask? {
        return nil
    }

    public func publisher() -> AnyPublisher<Int, Never> {
        return Just(1).eraseToAnyPublisher()
    }

    public func eventPublisher() -> AnyPublisher<DownloadManagerEvent, Never> {
        return Just(
            .canceled(
                [
                    .init(
                        id: "",
                        blockId: "",
                        courseId: "",
                        userId: 0,
                        url: "",
                        fileName: "",
                        displayName: "",
                        progress: 1,
                        resumeData: nil,
                        state: .inProgress,
                        type: .video,
                        fileSize: 0
                    )
                ]
            )
        ).eraseToAnyPublisher()
    }

    public func addToDownloadQueue(blocks: [CourseBlock]) {
        
    }

    public func getDownloadTasks() -> [DownloadDataTask] {
        []
    }

    public func getDownloadTasksForCourse(_ courseId: String) async -> [DownloadDataTask] {
        await withCheckedContinuation { continuation in
            continuation.resume(returning: [])
        }
    }

    public func cancelDownloading(courseId: String, blocks: [CourseBlock]) async throws {

    }

    public func cancelDownloading(task: DownloadDataTask) {

    }

    public func cancelDownloading(courseId: String) async {

    }

    public func cancelAllDownloading() async throws {

    }

    public func resumeDownloading() {
        
    }
    
    public func deleteFile(blocks: [CourseBlock]) {
        
    }
    
    public func deleteAll() {
        
    }
    
    public func fileUrl(for blockId: String) -> URL? {
        return nil
    }

    public func isLargeVideosSize(blocks: [CourseBlock]) -> Bool {
        false
    }

    public func removeAppSupportDirectoryUnusedContent() {
        
    }
}
#endif
// swiftlint:enable file_length
