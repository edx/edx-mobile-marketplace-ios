//
//  CourseScreensViewModel.swift
//  Course
//
//  Created by  Stepanok Ivan on 10.10.2022.
//

import Foundation
import SwiftUI
import Core
import Combine

// swiftlint:disable file_length
enum ContentTab: CaseIterable {
    case all
    case videos
    case assignments
    
    var title: String {
        switch self {
        case .all:
            return CourseLocalization.CourseContent.all
        case .videos:
            return CourseLocalization.CourseContent.videos
        case .assignments:
            return CourseLocalization.CourseContent.assignments
        }
    }
}

public enum CourseTab: Int, CaseIterable, Identifiable {
    public var id: Int {
        rawValue
    }
    case course
    case videos
    case dates
    case discussion
    case handounds
}

extension CourseTab {
    public var title: String {
        switch self {
        case .course:
            return CourseLocalization.CourseContainer.home
        case .videos:
            return CourseLocalization.CourseContainer.videos
        case .dates:
            return CourseLocalization.CourseContainer.dates
        case .discussion:
            return CourseLocalization.CourseContainer.discussions
        case .handounds:
            return CourseLocalization.CourseContainer.handouts
        }
    }

    public var image: Image {
        switch self {
        case .course:
            return CoreAssets.home.swiftUIImage.renderingMode(.template)
        case .videos:
            return CoreAssets.videos.swiftUIImage.renderingMode(.template)
        case .dates:
            return CoreAssets.dates.swiftUIImage.renderingMode(.template)
        case .discussion:
            return  CoreAssets.discussions.swiftUIImage.renderingMode(.template)
        case .handounds:
            return CoreAssets.more.swiftUIImage.renderingMode(.template)
        }
    }
}

public class CourseContainerViewModel: BaseCourseViewModel {
    
    @Published var selectedTab: ContentTab = .all
    @Published var tabBarIndex = 0
    @Published var courseAssignmentsStructure: CourseStructure?
    @Published var courseProgressDetails: CourseProgressDetails?
    @Published private(set) var assignmentSectionsData: [AssignmentSection] = []

    @Published public var selection: Int
    @Published var tabs: [CourseTab] = CourseTab.allCases.filter { $0 != .discussion }
    @Published var isShowProgress = true
    @Published var isShowRefresh = false
    @Published var canShowBanner = false
    @Published var courseStructure: CourseStructure? {
        didSet {
            courseStructureSubject.value = courseStructure
        }
    }
    @Published var courseDeadlineInfo: CourseDateBanner?
    @Published var courseVideosStructure: CourseStructure?
    @Published var showError: Bool = false
    @Published var sequentialsDownloadState: [String: DownloadViewState] = [:]
    @Published private(set) var downloadableVerticals: Set<VerticalsDownloadState> = []
    @Published var continueWith: ContinueWith?
    @Published var userSettings: UserSettings?
    @Published var isInternetAvaliable: Bool = true
    @Published var dueDatesShifted: Bool = false
    @Published var shouldHideMenuBar: Bool = false
    @Published var updateCourseProgress: Bool = false
    
    private var courseStructureSubject = CurrentValueSubject<CourseStructure?, Never>(nil)
    
    public var courseStructurePublisher: AnyPublisher<CourseStructure?, Never> {
        courseStructureSubject.eraseToAnyPublisher()
    }
    
    let completionPublisher = NotificationCenter.default.publisher(for: .onblockCompletionRequested)

    var errorMessage: String? {
        didSet {
            withAnimation {
                showError = errorMessage != nil
            }
        }
    }
    
    @Published var shouldShowUpgradeButton: Bool = false
        
    var sku: String? {
        courseStructure?.sku
    }
    
    let router: CourseRouter
    let config: ConfigProtocol
    let connectivity: ConnectivityProtocol

    let isActive: Bool?
    let courseStart: Date?
    let courseEnd: Date?
    let enrollmentStart: Date?
    let enrollmentEnd: Date?
    private var lastVisitedBlockID: String?

    var courseDownloadTasks: [DownloadDataTask] = []
    private(set) var waitingDownloads: [CourseBlock]?

    private let interactor: CourseInteractorProtocol
    private let authInteractor: AuthInteractorProtocol
    private let enrollmentInteractor: EnrollmentInteractorProtocol
    let analytics: CourseAnalytics
    let coreAnalytics: CoreAnalytics
    private(set) var storage: CourseStorage
    private var courseID: String?
    private var canShowTrackSelection: Bool
    let serverConfig: ServerConfigProtocol
    var enrollmentDetails: EnrollmentDetails?
    
    public init(
        interactor: CourseInteractorProtocol,
        authInteractor: AuthInteractorProtocol,
        enrollmentInteractor: EnrollmentInteractorProtocol,
        router: CourseRouter,
        analytics: CourseAnalytics,
        config: ConfigProtocol,
        connectivity: ConnectivityProtocol,
        manager: DownloadManagerProtocol,
        storage: CourseStorage,
        isActive: Bool?,
        courseStart: Date?,
        courseEnd: Date?,
        enrollmentStart: Date?,
        enrollmentEnd: Date?,
        lastVisitedBlockID: String?,
        coreAnalytics: CoreAnalytics,
        selection: CourseTab = CourseTab.course,
        showTrackSelection: Bool = false,
        serverConfig: ServerConfigProtocol
    ) {
        self.interactor = interactor
        self.authInteractor = authInteractor
        self.enrollmentInteractor = enrollmentInteractor
        self.router = router
        self.analytics = analytics
        self.config = config
        self.connectivity = connectivity
        self.isActive = isActive
        self.courseStart = courseStart
        self.courseEnd = courseEnd
        self.enrollmentStart = enrollmentStart
        self.enrollmentEnd = enrollmentEnd
        self.storage = storage
        self.userSettings = storage.userSettings
        self.isInternetAvaliable = connectivity.isInternetAvaliable
        self.lastVisitedBlockID = lastVisitedBlockID
        self.coreAnalytics = coreAnalytics
        self.selection = selection.rawValue
        self.canShowTrackSelection = showTrackSelection
        self.serverConfig = serverConfig
        
        super.init(manager: manager)
        addObservers()
    }
    
    @MainActor
    func updateCourseIfNeeded(courseID: String) async {
        if updateCourseProgress {
            await getCourseBlocks(courseID: courseID, withProgress: false)
            await MainActor.run {
                updateCourseProgress = false
            }
        }
    }

    func openLastVisitedBlock() {
        guard let continueWith = continueWith,
              let courseStructure = courseStructure else { return }
        let chapter = courseStructure.childs[continueWith.chapterIndex]
        let sequential = chapter.childs[continueWith.sequentialIndex]
        let continueUnit = sequential.childs[continueWith.verticalIndex]
        
        var continueBlock: CourseBlock?
        continueUnit.childs.forEach { block in
            if block.id == continueWith.lastVisitedBlockId {
                continueBlock = block
            }
        }
        
        trackResumeCourseClicked(
            blockId: continueBlock?.id ?? ""
        )
        
        router.showCourseUnit(
            courseName: courseStructure.displayName,
            blockId: continueBlock?.id ?? "",
            courseID: courseStructure.id,
            verticalIndex: continueWith.verticalIndex,
            chapters: courseStructure.childs,
            chapterIndex: continueWith.chapterIndex,
            sequentialIndex: continueWith.sequentialIndex,
            courseStructurePublisher: courseStructurePublisher
        )
        
        self.lastVisitedBlockID = nil
    }
    
    @MainActor
    func reload(courseID: String) async {
        updateMenuBarVisibility()
        self.courseID = courseID
        await withTaskGroup(of: Void.self) {[weak self] group in
            guard let self = self else { return }
            group.addTask {
                await self.getEnrollmentDetails(courseID: courseID)
            }
            group.addTask {
                await self.getCourseBlocks(courseID: courseID)
            }
            group.addTask {
                await self.getCourseDeadlineInfo(courseID: courseID, withProgress: false)
            }
        }
    }

    @MainActor
    func getCourseStructure(courseID: String) async throws -> CourseStructure? {
        if isInternetAvaliable {
            return try await interactor.getCourseBlocks(courseID: courseID)
        } else {
            return try await interactor.getLoadedCourseBlocks(courseID: courseID)
        }
    }
    
    @MainActor
    func updateMenuBarVisibility() {
        if #available(iOS 16.0, *) {
            shouldHideMenuBar =
                courseStructure == nil ||
                courseStructure?.coursewareAccessDetails?.coursewareAccess?.hasAccess == false
        } else {
            shouldHideMenuBar = true
        }
    }

    @MainActor
    func updateBannerVisibilityStatus(forCourse courseID: String, dateBanner: CourseDateBanner? = nil) {
        let data = dateBanner ?? courseDeadlineInfo

        canShowBanner = interactor.canShowBanner(
            data?.datesBannerInfo.status?.storageBannerType,
            forCourse: courseID
        )
    }

    @MainActor
    func getCourseBlocks(courseID: String, withProgress: Bool = true) async {
        isShowProgress = withProgress
        isShowRefresh = !withProgress
        
        async let structureTask = getCourseStructure(courseID: courseID)
        async let progressTask: CourseProgressDetails? = {
            do {
                if isInternetAvaliable {
                    return try await interactor.getCourseProgress(courseID: courseID)
                } else {
                    return try await interactor.getCourseProgressOffline(courseID: courseID)
                }
            } catch {
                debugLog("Failed to load course progress: \(error.localizedDescription)")
                return nil
            }
        }()
        
        do {
            guard let courseStructure = try await structureTask else {
                throw NSError(
                    domain: "GetCourseBlocks",
                    code: 0,
                    userInfo: [NSLocalizedDescriptionKey: "Course structure is nil"]
                )
            }
            
            await setDownloadsStates(courseStructure: courseStructure)
            self.courseStructure = courseStructure
            let type = type(for: courseStructure.coursewareAccessDetails?.coursewareAccess)
            shouldShowUpgradeButton = type == nil
            && courseStructure.isUpgradeable
            && serverConfig.iapConfig.enabled

            if shouldShowUpgradeButton && canShowTrackSelection {
                showTrackSelection()
            }
            canShowTrackSelection = false
            
            // progress may still be downloading; assign when ready
            self.courseProgressDetails = await progressTask
            
            async let videosTask = interactor.getCourseVideoBlocks(fullStructure: courseStructure)
            async let assignmentsTask = interactor.getCourseAssignmentBlocks(fullStructure: courseStructure)
            
            courseVideosStructure = await videosTask
            courseAssignmentsStructure = await assignmentsTask
            updateAssignmentSections()

            updateMenuBarVisibility()

            if isInternetAvaliable {
                NotificationCenter.default.post(name: .getCourseDates, object: courseID)
                try await getResumeBlock(
                    courseID: courseID,
                    courseStructure: courseStructure
                )
            }
            isShowProgress = false
            isShowRefresh = false
            
        } catch {
            isShowProgress = false
            isShowRefresh = false
            shouldShowUpgradeButton = false
            courseAssignmentsStructure = nil
            courseProgressDetails = nil
            assignmentSectionsData = []
            if courseStructure?.coursewareAccessDetails?.coursewareAccess?.errorCode == .unknown {
                courseStructure = nil
                courseVideosStructure = nil
            }
        }
    }
    
    @MainActor
    func getCourseDeadlineInfo(courseID: String, withProgress: Bool = true) async {
        guard let courseStart, courseStart < Date() else { return }
        do {
            let courseDeadlineInfo = try await interactor.getCourseDeadlineInfo(courseID: courseID)
            updateBannerVisibilityStatus(forCourse: courseID, dateBanner: courseDeadlineInfo)

            withAnimation {
                self.courseDeadlineInfo = courseDeadlineInfo
            }
        } catch let error {
            debugLog(error.localizedDescription)
        }
    }
    
    @MainActor
    func getEnrollmentDetails(courseID: String) async {
        do {
            let enrollmentDetails = try await enrollmentInteractor.getEnrollmentDetails(courseID: courseID)
            self.enrollmentDetails = enrollmentDetails

            tabs = CourseTab.allCases
            if enrollmentDetails.discussionURL == nil {
                tabs.removeAll { $0 == .discussion }
            }
        } catch let error {
            debugLog(error.localizedDescription)
        }
    }

    @MainActor
    func shiftDueDates(courseID: String, withProgress: Bool = true, screen: DatesStatusInfoScreen, type: String) async {
        isShowProgress = withProgress
        isShowRefresh = !withProgress
        
        do {
            try await interactor.shiftDueDates(courseID: courseID)
            NotificationCenter.default.post(name: .shiftCourseDates, object: courseID)
            isShowProgress = false
            isShowRefresh = false
            
            analytics.plsSuccessEvent(
                .plsShiftDatesSuccess,
                bivalue: .plsShiftDatesSuccess,
                courseID: courseID,
                screenName: screen.rawValue,
                type: type,
                success: true
            )
            
        } catch let error {
            isShowProgress = false
            isShowRefresh = false
            analytics.plsSuccessEvent(
                .plsShiftDatesSuccess,
                bivalue: .plsShiftDatesSuccess,
                courseID: courseID,
                screenName: screen.rawValue,
                type: type,
                success: false
            )
            if error.isInternetError || error is NoCachedDataError {
                errorMessage = CoreLocalization.Error.slowOrNoInternetConnection
            } else {
                errorMessage = CoreLocalization.Error.unknownError
            }
        }
    }
    
    private func date(from stringDate: String?) -> Date? {
        guard let stringDate else { return nil }
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return dateFormatter.date(from: stringDate)
    }
    
    func type(for access: CoursewareAccess?) -> CourseAccessErrorHelperType? {
        guard let access, !access.hasAccess else { return nil }
        
        if let courseEnd, courseEnd.isInPast() {
            if courseStructure?.isUpgradeable == true {
                guard let courseStructure, let courseID else { return nil }
                return .upgradeable(
                    date: courseEnd,
                    sku: courseStructure.sku ?? "",
                    courseID: courseID,
                    pacing: courseStructure.isSelfPaced ? Pacing.selfPace.rawValue : Pacing.instructor.rawValue,
                    screen: .courseDashboard,
                    lmsPrice: courseStructure.lmsPrice ?? .zero
                )
            } else {
                return .isEndDateOld(date: courseEnd)
            }
        } else {
            guard let errorCode = access.errorCode else { return nil }
            
            switch errorCode {
            case .notStarted:
                return .startDateError(date: courseStart)
            case .auditExpired:
                guard
                    let courseStructure,
                    let courseID,
                    let dateString = courseStructure.coursewareAccessDetails?.auditAccessExpires,
                    let date = date(from: dateString)
                else { return nil }
                return .auditExpired(
                    date: date,
                    sku: courseStructure.sku ?? "",
                    courseID: courseID,
                    pacing: courseStructure.isSelfPaced ? Pacing.selfPace.rawValue : Pacing.instructor.rawValue,
                    screen: .courseDashboard,
                    lmsPrice: courseStructure.lmsPrice ?? .zero
                )
            
            default:
                return nil
            }
        }
    }
    
    func update(downloadQuality: DownloadQuality) {
        storage.userSettings?.downloadQuality = downloadQuality
        userSettings = storage.userSettings
    }

    @MainActor
    func tryToRefreshCookies() async {
        try? await authInteractor.getCookies(force: false)
    }
    
    @MainActor
    private func getResumeBlock(courseID: String, courseStructure: CourseStructure) async throws {
        if let lastVisitedBlockID {
            self.continueWith = findContinueVertical(
                blockID: lastVisitedBlockID,
                courseStructure: courseStructure
            )
            openLastVisitedBlock()
        } else {
            let result = try await interactor.resumeBlock(courseID: courseID)
            withAnimation {
                self.continueWith = findContinueVertical(
                    blockID: result.blockID,
                    courseStructure: courseStructure
                )
            }
        }
    }

    @MainActor
    func onDownloadViewTap(chapter: CourseChapter, state: DownloadViewState) async {
        let blocks = chapter.childs
            .flatMap { $0.childs }
            .flatMap { $0.childs }
            .filter { $0.isDownloadable }

        if state == .available, isShowedAllowLargeDownloadAlert(blocks: blocks) {
            return
        }

        if state == .available {
            analytics.bulkDownloadVideosSection(
                courseID: courseStructure?.id ?? "",
                sectionID: chapter.id,
                videos: blocks.count
            )
        } else if state == .finished {
            analytics.bulkDeleteVideosSection(
                courseID: courseStructure?.id ?? "",
                sectionId: chapter.id,
                videos: blocks.count
            )
        }

        await download(state: state, blocks: blocks)
    }

    @MainActor
    func showTrackSelection() {
        guard let structure = courseStructure,
              let sku = courseStructure?.sku,
              let lmsPrice = courseStructure?.lmsPrice,
              let accessExpires = date(from: structure.coursewareAccessDetails?.auditAccessExpires)
        else { return }

        router.showTrackSelection(
            courseID: structure.id,
            productName: structure.displayName,
            sku: sku,
            pacing: structure.isSelfPaced ? Pacing.selfPace.rawValue : Pacing.instructor.rawValue,
            lmsPrice: lmsPrice,
            accessExpires: accessExpires
        )
    }

    func showPaymentsInfo() {
        guard let structure = courseStructure,
              let sku = courseStructure?.sku,
              let lmsPrice = courseStructure?.lmsPrice
        else { return }
        
        Task {@MainActor in
            await router.showUpgradeInfo(
                productName: structure.displayName,
                message: "",
                sku: sku,
                courseID: structure.id,
                screen: .courseDashboard,
                pacing: structure.isSelfPaced ? Pacing.selfPace.rawValue : Pacing.instructor.rawValue,
                lmsPrice: lmsPrice
            )
        }
    }

    func dismissBanner(forCourse courseID: String) {
        guard let banner = courseDeadlineInfo?.datesBannerInfo.status else {
            return
        }

        interactor.markBannerDismissed(banner.storageBannerType, forCourse: courseID)
        canShowBanner = false

        analytics.plsEvent(
            .plsBannerDismissed,
            bivalue: .plsBannerDismissed,
            courseID: courseID,
            screenName: DatesStatusInfoScreen.courseDashbaord.rawValue,
            type: banner.analyticsBannerType
        )
    }

    func verticalsBlocksDownloadable(by courseSequential: CourseSequential) -> [CourseBlock] {
        let verticals = downloadableVerticals.filter { verticalState in
            courseSequential.childs.contains(where: { item in
                return verticalState.vertical.id == item.id
            })
        }
        return verticals.flatMap { $0.vertical.childs.filter { $0.isDownloadable } }
    }

    func getTasks(sequential: CourseSequential) -> [DownloadDataTask] {
        let blocks = verticalsBlocksDownloadable(by: sequential)
        let tasks = blocks.compactMap { block in
            courseDownloadTasks.first(where: { $0.id ==  block.id})
        }
        return tasks
    }

    func continueDownload() async {
        guard let blocks = waitingDownloads else {
            return
        }
        do {
            try await manager.addToDownloadQueue(blocks: blocks)
        } catch let error {
            if error is NoWiFiError {
                await MainActor.run {
                    errorMessage = CoreLocalization.Error.wifi
                }
            }
        }
    }

    func trackSelectedTab(
        selection: CourseTab,
        courseId: String,
        courseName: String
    ) {
        switch selection {
        case .course:
            analytics.courseOutlineCourseTabClicked(courseId: courseId, courseName: courseName)
        case .videos:
            analytics.courseOutlineVideosTabClicked(courseId: courseId, courseName: courseName)
        case .dates:
            analytics.courseOutlineDatesTabClicked(courseId: courseId, courseName: courseName)
        case .discussion:
            analytics.courseOutlineDiscussionTabClicked(courseId: courseId, courseName: courseName)
        case .handounds:
            analytics.courseOutlineHandoutsTabClicked(courseId: courseId, courseName: courseName)
        }
    }

    func trackVerticalClicked(
        courseId: String,
        courseName: String,
        vertical: CourseVertical
    ) {
        analytics.verticalClicked(
            courseId: courseId,
            courseName: courseName,
            blockId: vertical.blockId,
            blockName: vertical.displayName
        )
    }
    
    func trackViewCertificateClicked(courseID: String) {
        analytics.trackCourseEvent(
            .courseViewCertificateClicked,
            biValue: .courseViewCertificateClicked,
            courseID: courseID
        )
    }

    func trackSequentialClicked(_ sequential: CourseSequential) {
        guard let course = courseStructure else { return }
        analytics.sequentialClicked(
            courseId: course.id,
            courseName: course.displayName,
            blockId: sequential.blockId,
            blockName: sequential.displayName
        )
    }
    
    func trackResumeCourseClicked(blockId: String) {
        guard let course = courseStructure else { return }
        analytics.resumeCourseClicked(
            courseId: course.id,
            courseName: course.displayName,
            blockId: blockId
        )
    }
    
    func trackCourseHomeGradesViewProgressClicked() {
        guard let course = courseStructure else { return }
        analytics.courseHomeGradesViewProgressClicked(
            courseId: course.id,
            courseName: course.displayName
        )
    }
    
    func trackCourseHomeViewAllContentClicked() {
        guard let course = courseStructure else { return }
        analytics.courseHomeViewAllContentClicked(
            courseId: course.id,
            courseName: course.displayName
        )
    }
    
    func trackCourseHomeAssignmentClicked(blockId: String, blockName: String) {
        guard let course = courseStructure else { return }
        analytics.courseHomeAssignmentClicked(courseId: course.id,
                                         courseName: course.displayName,
                                         blockId: blockId,
                                         blockName: blockName
        )
    }
    
    func trackCourseHomeViewAllVideosClicked() {
        guard let course = courseStructure else { return }
        analytics.courseHomeViewAllVideosClicked(
            courseId: course.id,
            courseName: course.displayName
        )
    }
    
    func trackCourseHomeViewAllAssignmentsClicked() {
        guard let course = courseStructure else { return }
        analytics.courseHomeViewAllAssignmentsClicked(
            courseId: course.id,
            courseName: course.displayName
        )
    }
    
    func trackShowCompletedSubsectionClicked() {
        guard let course = courseStructure else { return }
        analytics.contentPageShowCompletedSubsectionClicked(
            courseId: course.id,
            courseName: course.displayName
        )
    }
    
    func trackCourseHomeVideoClicked(blockId: String, blockName: String) {
        guard let course = courseStructure else { return }
        analytics.courseHomeVideoClicked(courseId: course.id,
                                         courseName: course.displayName,
                                         blockId: blockId,
                                         blockName: blockName
        )
    }
    
    func trackCourseHomeSectionClicked(section: String, subsection: String) {
        guard let course = courseStructure else { return }
        analytics.courseHomeSectionSubsectionClick(
            courseId: course.id,
            courseName: course.displayName,
            courseSection: section,
            courseSubsection: subsection
        )
    }
    
    func trackAssignmentClicked(_ sequential: CourseSequential) {
        guard let course = courseStructure else { return }
        analytics.courseAssignmentClicked(
            courseId: course.id,
            courseName: course.displayName,
            blockId: sequential.blockId,
            blockName: sequential.displayName
        )
    }

    func completeBlock(
        chapterID: String,
        sequentialID: String,
        verticalID: String,
        blockID: String
    ) {
        guard let chapterIndex = courseStructure?
            .childs.firstIndex(where: { $0.id == chapterID }) else {
            return
        }
        guard let sequentialIndex = courseStructure?
            .childs[chapterIndex]
            .childs.firstIndex(where: { $0.id == sequentialID }) else {
            return
        }

        guard let verticalIndex = courseStructure?
            .childs[chapterIndex]
            .childs[sequentialIndex]
            .childs.firstIndex(where: { $0.id == verticalID }) else {
            return
        }

        guard let blockIndex = courseStructure?
            .childs[chapterIndex]
            .childs[sequentialIndex]
            .childs[verticalIndex]
            .childs.firstIndex(where: { $0.id == blockID }) else {
            return
        }

        courseStructure?
            .childs[chapterIndex]
            .childs[sequentialIndex]
            .childs[verticalIndex]
            .childs[blockIndex].completion = 1
        courseStructure.map {
            courseVideosStructure = interactor.getCourseVideoBlocks(fullStructure: $0)
        }
    }

    func hasVideoForDowbloads() -> Bool {
        guard let courseVideosStructure = courseVideosStructure else {
            return false
        }
        return courseVideosStructure.childs
            .flatMap { $0.childs }
            .contains(where: { $0.isDownloadable })
    }

    func isAllDownloading() -> Bool {
        let totalCount = downloadableVerticals.count
        let downloadingCount = downloadableVerticals.filter { $0.state == .downloading }.count
        let finishedCount = downloadableVerticals.filter { $0.state == .finished }.count
        if finishedCount == totalCount { return false }
        return totalCount - finishedCount == downloadingCount
    }

    @MainActor
    func download(state: DownloadViewState, blocks: [CourseBlock]) async {
        do {
            switch state {
            case .available:
                try await manager.addToDownloadQueue(blocks: blocks)
            case .downloading:
                try await manager.cancelDownloading(courseId: courseStructure?.id ?? "", blocks: blocks)
            case .finished:
                if let courseID {
                    await manager.delete(blocks: blocks, courseId: courseID)
                }
            }
        } catch let error {
            if error is NoWiFiError {
                errorMessage = CoreLocalization.Error.wifi
            }
        }
    }

    @MainActor
    func isShowedAllowLargeDownloadAlert(blocks: [CourseBlock]) -> Bool {
        waitingDownloads = nil
        if storage.allowedDownloadLargeFile == false, manager.isLargeVideosSize(blocks: blocks) {
            waitingDownloads = blocks
            router.presentAlert(
                alertTitle: CourseLocalization.Download.download,
                alertMessage: CourseLocalization.Download.downloadLargeFileMessage,
                positiveAction: CourseLocalization.Alert.accept,
                onCloseTapped: {
                    self.router.dismiss(animated: true)
                },
                okTapped: {
                    Task {
                        await self.continueDownload()
                    }
                    self.router.dismiss(animated: true)
                },
                type: .default(positiveAction: CourseLocalization.Alert.accept, image: nil)
            )
            return true
        }
        return false
    }

    @MainActor
    func downloadableBlocks(from sequential: CourseSequential) -> [CourseBlock] {
        let verticals = sequential.childs
        let blocks = verticals
            .flatMap { $0.childs }
            .filter { $0.isDownloadable }
        return blocks
    }

    @MainActor
    func setDownloadsStates(courseStructure: CourseStructure?) async {
        guard let course = courseStructure else { return }
        courseDownloadTasks = await manager.getDownloadTasksForCourse(course.id)
        downloadableVerticals = []
        var sequentialsStates: [String: DownloadViewState] = [:]
        for chapter in course.childs {
            for sequential in chapter.childs where sequential.isDownloadable {
                var sequentialsChilds: [DownloadViewState] = []
                for vertical in sequential.childs where vertical.isDownloadable {
                    var verticalsChilds: [DownloadViewState] = []
                    for block in vertical.childs where block.isDownloadable {
                        if let download = courseDownloadTasks.first(where: { $0.blockId == block.id }) {
                            switch download.state {
                            case .waiting, .inProgress:
                                sequentialsChilds.append(.downloading)
                                verticalsChilds.append(.downloading)
                            case .finished:
                                sequentialsChilds.append(.finished)
                                verticalsChilds.append(.finished)
                            }
                        } else {
                            sequentialsChilds.append(.available)
                            verticalsChilds.append(.available)
                        }
                    }
                    if verticalsChilds.first(where: { $0 == .downloading }) != nil {
                        downloadableVerticals.insert(.init(vertical: vertical, state: .downloading))
                    } else if verticalsChilds.allSatisfy({ $0 == .finished }) {
                        downloadableVerticals.insert(.init(vertical: vertical, state: .finished))
                    } else {
                        downloadableVerticals.insert(.init(vertical: vertical, state: .available))
                    }
                }
                if sequentialsChilds.first(where: { $0 == .downloading }) != nil {
                    sequentialsStates[sequential.id] = .downloading
                } else if sequentialsChilds.allSatisfy({ $0 == .finished }) {
                    sequentialsStates[sequential.id] = .finished
                } else {
                    sequentialsStates[sequential.id] = .available
                }
            }
            self.sequentialsDownloadState = sequentialsStates
        }
    }
    
    private func findContinueVertical(blockID: String, courseStructure: CourseStructure) -> ContinueWith? {
        for chapterIndex in courseStructure.childs.indices {
            let chapter = courseStructure.childs[chapterIndex]
            for sequentialIndex in chapter.childs.indices {
                let sequential = chapter.childs[sequentialIndex]
                for verticalIndex in sequential.childs.indices {
                    let vertical = sequential.childs[verticalIndex]
                    for block in vertical.childs where block.id == blockID {
                        return ContinueWith(
                            chapterIndex: chapterIndex,
                            sequentialIndex: sequentialIndex,
                            verticalIndex: verticalIndex,
                            lastVisitedBlockId: block.id
                        )
                    }
                }
            }
        }
        return nil
    }

    private func addObservers() {
        manager.eventPublisher()
            .sink { [weak self] state in
                guard let self else { return }
                if case .progress = state { return }
                debugLog(state, "--- state ---")
                Task {
                    await self.setDownloadsStates(courseStructure: self.courseStructure)
                }
            }
            .store(in: &cancellables)

        connectivity.internetReachableSubject
            .sink { [weak self] _ in
            guard let self else { return }
                self.isInternetAvaliable = self.connectivity.isInternetAvaliable
        }
        .store(in: &cancellables)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleShiftDueDates),
            name: .shiftCourseDates, object: nil
        )
        
        NotificationCenter.default
            .publisher(for: .courseUpgradeCompletionNotification)
            .sink { [weak self] _ in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    Task {
                        if let courseID = self.courseID {
                            await self.reload(courseID: courseID)
                        }
                    }
                }
            }
            .store(in: &cancellables)
        
        completionPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                updateCourseProgress = true
            }
            .store(in: &cancellables)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension CourseContainerViewModel {
    @objc private func handleShiftDueDates(_ notification: Notification) {
        if let courseID = notification.object as? String {
            Task {
                await withTaskGroup(of: Void.self) { group in
                    group.addTask {
                        await self.getCourseBlocks(courseID: courseID, withProgress: true)
                    }
                    group.addTask {
                        await self.getCourseDeadlineInfo(courseID: courseID, withProgress: true)
                    }
                    await MainActor.run { [weak self] in
                        self?.dueDatesShifted = true
                    }
                }
            }
        }
    }
    
    func resetDueDatesShiftedFlag() {
        dueDatesShifted = false
    }
}

// MARK: - CourseProgress
extension CourseContainerViewModel {
    
    @MainActor
    func collectBlocks(
        chapter: CourseChapter,
        blockId: String,
        state: DownloadViewState,
        videoOnly: Bool = false
    ) async -> [CourseBlock] {
        let sequentials = chapter.childs.filter { $0.id == blockId }
        guard !sequentials.isEmpty else { return [] }
        
        let blocks = sequentials.flatMap { $0.childs.flatMap { $0.childs } }
            .filter { $0.isDownloadable && (!videoOnly || $0.type == .video) }
        
        if state == .available, isShowedAllowLargeDownloadAlert(blocks: blocks) {
            return []
        }
        
        guard let sequential = chapter.childs.first(where: { $0.id == blockId }) else {
            return []
        }
        
        if state == .available {
            analytics.bulkDownloadVideosSubsection(
                courseID: courseStructure?.id ?? "",
                sectionID: chapter.id,
                subSectionID: sequential.id,
                videos: blocks.count
            )
        } else if state == .finished {
            analytics.bulkDeleteVideosSubsection(
                courseID: courseStructure?.id ?? "",
                subSectionID: sequential.id,
                videos: blocks.count
            )
        }
        
        return blocks
    }
    
    func chapterProgressDeep(for chapter: CourseChapter) -> Double {
        let allBlocks: [CourseBlock] = chapter.childs
            .flatMap { $0.childs }
            .flatMap { $0.childs }

        guard !allBlocks.isEmpty else { return 0.0 }

        let total = allBlocks.reduce(0.0) { $0 + $1.completion }
        let averageProgress = total / Double(allBlocks.count)
        return max(0.0, min(1.0, averageProgress))
    }
    
    func chapterCompletionPercentProgress(for chapter: CourseChapter) -> Int {
        let allBlocks: [CourseBlock] = chapter.childs
            .flatMap { $0.childs }
            .flatMap { $0.childs }

        guard !allBlocks.isEmpty else { return 0 }

        let total = allBlocks.reduce(0.0) { $0 + $1.completion }
        let averageProgress = Int(total / Double(allBlocks.count) * 100)
        return averageProgress
    }
    
    func assignmentTypeColor(for assignmentType: String) -> String? {
        guard let progressDetails = courseProgressDetails else { return nil }

        guard let index = progressDetails.gradingPolicy.assignmentPolicies
            .firstIndex(where: { $0.type == assignmentType }) else {
            return nil
        }

        let colors = progressDetails.gradingPolicy.assignmentColors

        guard !colors.isEmpty else { return nil }

        let colorIndex = index % colors.count
        let hexColor = colors[colorIndex]

        return hexColor
    }
    
    private func updateAssignmentSections() {
        guard let progressDetails = courseProgressDetails else {
            assignmentSectionsData = []
            return
        }
        
        let subsectionsByType = Dictionary(
            grouping: progressDetails.sectionScores.flatMap { $0.subsections }
        ) { subsection in
            subsection.assignmentType ?? "unknown"
        }

        assignmentSectionsData = progressDetails.gradingPolicy.assignmentPolicies.compactMap { policy in
            guard
                let subsections = subsectionsByType[policy.type],
                !subsections.isEmpty
            else { return nil }

            let uiSubsections = createUIModels(from: subsections)

            return AssignmentSection(
                assignmentType: policy.type,
                label: policy.type,
                weight: policy.weight,
                subsections: uiSubsections
            )
        }
                
    }
    
    func assignmentSections() -> [AssignmentSection] {
        return assignmentSectionsData
    }
    
    // MARK: - Assignment Helper Methods

    private func createUIModels(from subsections: [CourseProgressSubsection]) -> [CourseProgressSubsectionUI] {
        return subsections.map { subsection in
            let shortLabel = getSequentialShortLabel(for: subsection.blockKey) ?? ""
            let status = getSequentialAssignmentStatus(for: subsection.blockKey) ?? getAssignmentStatus(for: subsection)
            let statusText = computeStatusText(for: subsection, status: status, shortLabel: shortLabel)
            let statusTextForCarousel = computeStatusTextForCarousel(
                for: subsection,
                status: status,
                shortLabel: shortLabel
            )
            let sequenceName = getAssignmentSequenceName(for: subsection)
            let sectionName = getAssignmentSectionName(for: subsection.blockKey)
            let date = getAssignmentDueDate(for: subsection)

            return CourseProgressSubsectionUI(
                subsection: subsection,
                statusText: statusText,
                statusTextForCarousel: statusTextForCarousel,
                sectionName: sectionName,
                sequenceName: sequenceName,
                status: status,
                shortLabel: shortLabel,
                date: date
            )
        }
    }

    func getSequentialShortLabel(for blockKey: String) -> String? {
        guard let courseStructure = courseAssignmentsStructure ?? courseStructure else { return nil }
        
        for chapter in courseStructure.childs {
            for sequential in chapter.childs {
                if sequential.blockId == blockKey || sequential.id == blockKey {
                    return sequential.sequentialProgress?.shortLabel
                }
            }
        }
        return nil
    }

    func getSequentialAssignmentStatus(for blockKey: String) -> AssignmentCardStatus? {
        guard let courseStructure = courseAssignmentsStructure ?? courseStructure else { return nil }
        
        for chapter in courseStructure.childs {
            for sequential in chapter.childs {
                if sequential.blockId == blockKey || sequential.id == blockKey {
                    if sequential.completion >= 1.0 {
                        return .completed
                    }
                    if let due = sequential.due, due < Date() {
                        return .pastDue
                    }
                    return .incomplete
                }
            }
        }
        return nil
    }

    func getAssignmentStatus(for subsection: CourseProgressSubsection) -> AssignmentCardStatus {
        guard subsection.learnerHasAccess else { return .notAvailable }
        if subsection.numPointsEarned >= subsection.numPointsPossible { return .completed }
        if isPastDue(subsection) { return .pastDue }
        return .incomplete
    }

    private func isPastDue(_ subsection: CourseProgressSubsection) -> Bool {
        guard let structure = courseAssignmentsStructure ?? courseStructure else { return false }
        let allSequentials = structure.childs.flatMap { $0.childs }
        if let seq = allSequentials.first(where: { $0.blockId == subsection.blockKey || $0.id == subsection.blockKey }),
           let due = seq.due,
           due < Date() {
            return true
        }
        return false
    }

    func getAssignmentDueDate(for subsection: CourseProgressSubsection) -> Date? {
        guard let courseStructure = courseAssignmentsStructure ?? courseStructure else { return nil }
        
        for chapter in courseStructure.childs {
            for sequential in chapter.childs {
                if sequential.blockId == subsection.blockKey || sequential.id == subsection.blockKey {
                    return sequential.due
                }
            }
        }
        return nil
    }

    func getAssignmentSectionName(for blockKey: String) -> String {
        guard let courseStructure = courseAssignmentsStructure ?? courseStructure else { return "" }

        for chapter in courseStructure.childs {
            for sequential in chapter.childs {
                if sequential.blockId == blockKey || sequential.id == blockKey {
                    return chapter.displayName
                }
            }
        }
        return ""
    }

    func getAssignmentSequenceName(for subsection: CourseProgressSubsection) -> String {
        guard let courseStructure = courseStructure else {
            return subsection.displayName
        }
        
        for chapter in courseStructure.childs {
            for sequential in chapter.childs {
                for vertical in sequential.childs where vertical.childs
                    .contains(where: { $0.id == subsection.blockKey }) {
                    return sequential.displayName
                }
            }
        }
        return subsection.displayName
    }

    func clearShortLabel(_ text: String) -> String {
        let words = text.split(separator: " ")

        guard let last = words.last, last.allSatisfy(\.isNumber) else {
            let letters = text.filter { !$0.isNumber }
            return String(letters.prefix(3)).uppercased()
        }

        let rightRaw = String(last)
        let leftRaw = words.dropLast().joined(separator: " ")
        let leftShort = String(leftRaw.filter { !$0.isNumber }.prefix(3)).uppercased()
        let rightClean = String(Int(rightRaw) ?? 0)

        return leftShort + rightClean
    }

    private func computeStatusText(
        for subsection: CourseProgressSubsection,
        status: AssignmentCardStatus,
        shortLabel: String?
    ) -> String {
        let cleanShortLabel = clearShortLabel(shortLabel ?? "")
        
        switch status {
        case .completed:
            return CourseLocalization.AssignmentStatus
                .complete(cleanShortLabel, Int(subsection.numPointsEarned), Int(subsection.numPointsPossible))
        case .pastDue:
            return CourseLocalization.AssignmentStatus
                .pastDue(cleanShortLabel, Int(subsection.numPointsEarned), Int(subsection.numPointsPossible))
        case .notAvailable:
            return CourseLocalization.AssignmentStatus.notYetAvailable(cleanShortLabel)
        case .incomplete:
            if let dueDate = getAssignmentDueDate(for: subsection) {
                return "\(cleanShortLabel) \(dueDate.timeAgoDisplay(dueIn: true))"
            } else {
                return CourseLocalization.AssignmentStatus
                    .inProgress(cleanShortLabel, Int(subsection.numPointsEarned), Int(subsection.numPointsPossible))
            }
        }
    }

    private func computeStatusTextForCarousel(
        for subsection: CourseProgressSubsection,
        status: AssignmentCardStatus,
        shortLabel: String?
    ) -> String {

        if let dueDate = getAssignmentDueDate(for: subsection) {
            switch status {
            case .pastDue:
                return "\(dueDate.formattedDueStatus())"
            case .incomplete:
                return "\(dueDate.formattedDueStatus())"
            default:
                break
            }
        }
        return ""
    }
    
    private func findChapterIndexInFullStructure(video: CourseBlock) -> Int? {
        guard let courseStructure = courseStructure else { return nil }
        
        // Find the chapter that contains this video in the full structure
        return courseStructure.childs.firstIndex { fullChapter in
            fullChapter.childs.contains { sequential in
                sequential.childs.contains { vertical in
                    vertical.childs.contains { $0.id == video.id }
                }
            }
        }
    }
    
    private func findSequentialIndexInFullStructure(video: CourseBlock) -> Int? {
        guard let courseStructure = courseStructure else { return nil }
        
        // Find the chapter and sequential that contains this video in the full structure
        for fullChapter in courseStructure.childs {
            if let sequentialIndex = fullChapter.childs.firstIndex(where: { sequential in
                sequential.childs.contains { vertical in
                    vertical.childs.contains { $0.id == video.id }
                }
            }) {
                return sequentialIndex
            }
        }
        return nil
    }
    
    private func findVerticalIndexInFullStructure(video: CourseBlock) -> Int? {
        guard let courseStructure = courseStructure else { return nil }
        
        // Find the vertical that contains this video in the full structure
        for fullChapter in courseStructure.childs {
            for sequential in fullChapter.childs {
                if let verticalIndex = sequential.childs.firstIndex(where: { vertical in
                    vertical.childs.contains { $0.id == video.id }
                }) {
                    return verticalIndex
                }
            }
        }
        return nil
    }
    
    func handleVideoTap(video: CourseBlock, chapter: CourseChapter?) {
        // TODO: Implement in navigation task
        guard let chapterIndex = findChapterIndexInFullStructure(video: video),
              let sequentialIndex = findSequentialIndexInFullStructure(video: video),
              let verticalIndex = findVerticalIndexInFullStructure(video: video),
              let courseStructure = courseStructure else {
            return
        }
        
        // Track video click analytics
        analytics.courseVideoClicked(
            courseId: courseStructure.id,
            courseName: courseStructure.displayName,
            blockId: video.id,
            blockName: video.displayName
        )
        
        router.showCourseUnit(
            courseName: courseStructure.displayName,
            blockId: video.id,
            courseID: courseStructure.id,
            verticalIndex: verticalIndex,
            chapters: courseStructure.childs,
            chapterIndex: chapterIndex,
            sequentialIndex: sequentialIndex,
            courseStructurePublisher: nil
        )
    }

    func navigateToAssignment(for subsection: CourseProgressSubsection) {
        // TODO: Implement in navigation task
        guard let courseStructure = courseStructure else { return }
        
        for (chapterIndex, chapter) in courseStructure.childs.enumerated() {
            for (sequentialIndex, sequential) in chapter.childs.enumerated()
            where sequential.id == subsection.blockKey {
                guard let courseVertical = sequential.childs.first else { return }
                guard let firstBlock = courseVertical.childs.first else {
                    router.showGatedContentError(url: courseVertical.webUrl)
                    return
                }
                
                trackAssignmentClicked(sequential)
                
                if config.uiComponents.courseDropDownNavigationEnabled {
                    router.showCourseUnit(
                        courseName: courseStructure.displayName,
                        blockId: firstBlock.id,
                        courseID: courseStructure.id,
                        verticalIndex: 0,
                        chapters: courseStructure.childs,
                        chapterIndex: chapterIndex,
                        sequentialIndex: sequentialIndex,
                        courseStructurePublisher: courseStructurePublisher
                    )
                } else {
                    router.showCourseVerticalView(
                        courseID: courseStructure.id,
                        courseName: courseStructure.displayName,
                        title: sequential.displayName,
                        chapters: courseStructure.childs,
                        chapterIndex: chapterIndex,
                        sequentialIndex: sequentialIndex,
                        courseStructurePublisher: courseStructurePublisher
                    )
                }
                return
            }
        }
    }
}

struct VerticalsDownloadState: Hashable {
    let vertical: CourseVertical
    let state: DownloadViewState

    var downloadableBlocks: [CourseBlock] {
        vertical.childs.filter { $0.isDownloadable }
    }
}
// swiftlint:enable file_length
