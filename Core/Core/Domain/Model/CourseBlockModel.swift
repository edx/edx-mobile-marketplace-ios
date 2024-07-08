//
//  CourseBlockModel.swift
//  Core
//
//  Created by  Stepanok Ivan on 14.03.2023.
//

import Foundation

public struct CourseStructure: Equatable {
    public static func == (lhs: CourseStructure, rhs: CourseStructure) -> Bool {
        return lhs.id == rhs.id
    }

    public let id: String
    public let graded: Bool
    public let completion: Double
    public let viewYouTubeUrl: String
    public let encodedVideo: String
    public let displayName: String
    public let topicID: String?
    public var childs: [CourseChapter]
    public let media: DataLayer.CourseMedia //FIXME Domain model
    public let certificate: Certificate?
    public let org: String
    public let isSelfPaced: Bool
    public let isUpgradeable: Bool
    public let sku: String?
    public let coursewareAccessDetails: CoursewareAccessDetails?
    public let courseProgress: CourseProgress?
    public let lmsPrice: Double?
    
    public init(
        id: String,
        graded: Bool,
        completion: Double,
        viewYouTubeUrl: String,
        encodedVideo: String,
        displayName: String,
        topicID: String? = nil,
        childs: [CourseChapter],
        media: DataLayer.CourseMedia,
        certificate: Certificate?,
        org: String,
        isSelfPaced: Bool,
        isUpgradeable: Bool,
        sku: String?,
        coursewareAccessDetails: CoursewareAccessDetails?,
        courseProgress: CourseProgress?,
        lmsPrice: Double?
    ) {
        self.id = id
        self.graded = graded
        self.completion = completion
        self.viewYouTubeUrl = viewYouTubeUrl
        self.encodedVideo = encodedVideo
        self.displayName = displayName
        self.topicID = topicID
        self.childs = childs
        self.media = media
        self.certificate = certificate
        self.org = org
        self.isSelfPaced = isSelfPaced
        self.isUpgradeable = isUpgradeable
        self.sku = sku
        self.coursewareAccessDetails = coursewareAccessDetails
        self.courseProgress = courseProgress
        self.lmsPrice = lmsPrice
    }

    public func totalVideosSizeInBytes(downloadQuality: DownloadQuality) -> Int {
        childs.flatMap {
            $0.childs.flatMap { $0.childs.flatMap { $0.childs.compactMap { $0 } } }
        }
        .filter { $0.isDownloadable }
        .compactMap { $0.encodedVideo?.video(downloadQuality: downloadQuality)?.fileSize }
        .reduce(.zero) { $0 + $1 }
    }

    public func totalVideosSizeInMb(downloadQuality: DownloadQuality) -> Double {
        Double(totalVideosSizeInBytes(downloadQuality: downloadQuality)) / 1024.0 / 1024.0
    }

    public func totalVideosSizeInGb(downloadQuality: DownloadQuality) -> Double {
        Double(totalVideosSizeInBytes(downloadQuality: downloadQuality)) / 1024.0 / 1024.0 / 1024.0
    }
    
    public func blockWithID(courseBlockId: String) -> CourseBlock? {
        let block = childs.flatMap {
            $0.childs.flatMap { $0.childs.flatMap { $0.childs.compactMap { $0 } } }
        }.filter { $0.id == courseBlockId }.first
        return block
    }
}

public struct CoursewareAccessDetails: Hashable {
    public let hasUNMETPrerequisites: Bool
    public let isTooEarly: Bool
    public let auditAccessExpires: String?
    public let coursewareAccess: CoursewareAccess?
    
    public init(
        hasUNMETPrerequisites: Bool,
        isTooEarly: Bool,
        auditAccessExpires: String?,
        coursewareAccess: CoursewareAccess?
    ) {
        self.hasUNMETPrerequisites = hasUNMETPrerequisites
        self.isTooEarly = isTooEarly
        self.auditAccessExpires = auditAccessExpires
        self.coursewareAccess = coursewareAccess
    }
    
    public static func == (lhs: CoursewareAccessDetails, rhs: CoursewareAccessDetails) -> Bool {
        lhs.hasUNMETPrerequisites == rhs.hasUNMETPrerequisites &&
        lhs.isTooEarly == rhs.isTooEarly &&
        lhs.auditAccessExpires == rhs.auditAccessExpires &&
        lhs.coursewareAccess == rhs.coursewareAccess
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(hasUNMETPrerequisites)
        hasher.combine(isTooEarly)
        hasher.combine(auditAccessExpires)
        hasher.combine(coursewareAccess)
    }
}

public struct CoursewareAccess: Hashable {
    public let hasAccess: Bool
    public let errorCode: CourseAccessError?
    public let developerMessage: String?
    public let userMessage: String?
    public let additionalContextUserMessage: String?
    public let userFragment: String?
    
    public init(
        hasAccess: Bool,
        errorCode: CourseAccessError?,
        developerMessage: String?,
        userMessage: String?,
        additionalContextUserMessage: String?,
        userFragment: String?
    ) {
        self.hasAccess = hasAccess
        self.errorCode = errorCode
        self.developerMessage = developerMessage
        self.userMessage = userMessage
        self.additionalContextUserMessage = additionalContextUserMessage
        self.userFragment = userFragment
    }
}

public enum CourseAccessError: String {
    case notStarted = "course_not_started"
    case auditExpired = "audit_expired"
    case visibilityError = "not_visible_to_user"
    case milestoneError = "unfulfilled_milestones"
    case unknown
}

public struct CourseProgress {
    public let totalAssignmentsCount: Int?
    public let assignmentsCompleted: Int?
    
    public init(totalAssignmentsCount: Int, assignmentsCompleted: Int) {
        self.totalAssignmentsCount = totalAssignmentsCount
        self.assignmentsCompleted = assignmentsCompleted
    }
}

public struct CourseChapter: Identifiable {

    public let blockId: String
    public let id: String
    public let displayName: String
    public let type: BlockType
    public var childs: [CourseSequential]
    
    public init(
        blockId: String,
        id: String,
        displayName: String,
        type: BlockType,
        childs: [CourseSequential]
    ) {
        self.blockId = blockId
        self.id = id
        self.displayName = displayName
        self.type = type
        self.childs = childs
    }
}

public struct CourseSequential: Identifiable {

    public let blockId: String
    public let id: String
    public let displayName: String
    public let type: BlockType
    public let completion: Double
    public var childs: [CourseVertical]
    public let sequentialProgress: SequentialProgress?
    public let due: Date?

    public var isDownloadable: Bool {
        return childs.first(where: { $0.isDownloadable }) != nil
    }
    
    public init(
        blockId: String,
        id: String,
        displayName: String,
        type: BlockType,
        completion: Double,
        childs: [CourseVertical],
        sequentialProgress: SequentialProgress?,
        due: Date?
    ) {
        self.blockId = blockId
        self.id = id
        self.displayName = displayName
        self.type = type
        self.completion = completion
        self.childs = childs
        self.sequentialProgress = sequentialProgress
        self.due = due
    }
}

public struct CourseVertical: Identifiable, Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public let blockId: String
    public let id: String
    public let courseId: String
    public let displayName: String
    public let type: BlockType
    public let completion: Double
    public var childs: [CourseBlock]
    
    public var isDownloadable: Bool {
        return childs.first(where: { $0.isDownloadable }) != nil
    }

    public init(
        blockId: String,
        id: String,
        courseId: String,
        displayName: String,
        type: BlockType,
        completion: Double,
        childs: [CourseBlock]
    ) {
        self.blockId = blockId
        self.id = id
        self.courseId = courseId
        self.displayName = displayName
        self.type = type
        self.completion = completion
        self.childs = childs
    }
}

public struct SubtitleUrl: Equatable {
    public let language: String
    public let url: String
    
    public init(language: String, url: String) {
        self.language = language
        self.url = url
    }
}

public struct SequentialProgress {
    public let assignmentType: String?
    public let numPointsEarned: Int?
    public let numPointsPossible: Int?
    
    public init(assignmentType: String?, numPointsEarned: Int?, numPointsPossible: Int?) {
        self.assignmentType = assignmentType
        self.numPointsEarned = numPointsEarned
        self.numPointsPossible = numPointsPossible
    }
}

public struct CourseBlock: Hashable, Identifiable {
    public static func == (lhs: CourseBlock, rhs: CourseBlock) -> Bool {
        lhs.id == rhs.id &&
        lhs.blockId == rhs.blockId &&
        lhs.completion == rhs.completion
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public let blockId: String
    public let id: String
    public let courseId: String
    public let topicId: String?
    public let graded: Bool
    public let due: Date?
    public var completion: Double
    public let type: BlockType
    public let displayName: String
    public let studentUrl: String
    public let webUrl: String
    public let subtitles: [SubtitleUrl]?
    public let encodedVideo: CourseBlockEncodedVideo?
    public let multiDevice: Bool?

    public var isDownloadable: Bool {
        encodedVideo?.isDownloadable ?? false
    }

    public init(
        blockId: String,
        id: String,
        courseId: String,
        topicId: String? = nil,
        graded: Bool,
        due: Date?,
        completion: Double,
        type: BlockType,
        displayName: String,
        studentUrl: String,
        webUrl: String,
        subtitles: [SubtitleUrl]? = nil,
        encodedVideo: CourseBlockEncodedVideo?,
        multiDevice: Bool?
    ) {
        self.blockId = blockId
        self.id = id
        self.courseId = courseId
        self.topicId = topicId
        self.graded = graded
        self.due = due
        self.completion = completion
        self.type = type
        self.displayName = displayName
        self.studentUrl = studentUrl
        self.webUrl = webUrl
        self.subtitles = subtitles
        self.encodedVideo = encodedVideo
        self.multiDevice = multiDevice
    }
}

public struct CourseBlockEncodedVideo {

    public let fallback: CourseBlockVideo?
    public let desktopMP4: CourseBlockVideo?
    public let mobileHigh: CourseBlockVideo?
    public let mobileLow: CourseBlockVideo?
    public let hls: CourseBlockVideo?
    public let youtube: CourseBlockVideo?

    public init(
        fallback: CourseBlockVideo?,
        youtube: CourseBlockVideo?,
        desktopMP4: CourseBlockVideo?,
        mobileHigh: CourseBlockVideo?,
        mobileLow: CourseBlockVideo?,
        hls: CourseBlockVideo?
    ) {
        self.fallback = fallback
        self.youtube = youtube
        self.desktopMP4 = desktopMP4
        self.mobileHigh = mobileHigh
        self.mobileLow = mobileLow
        self.hls = hls
    }

    public var isDownloadable: Bool {
        [hls, desktopMP4, mobileHigh, mobileLow, fallback]
            .contains { $0?.isDownloadable == true }
    }

    public func video(downloadQuality: DownloadQuality) -> CourseBlockVideo? {
        switch downloadQuality {
        case .auto:
            [mobileLow, mobileHigh, desktopMP4, fallback, hls]
                .first(where: { $0?.isDownloadable == true })?
                .flatMap { $0 }
        case .high:
            [desktopMP4, mobileHigh, mobileLow, fallback, hls]
                .first(where: { $0?.isDownloadable == true })?
                .flatMap { $0 }
        case .medium:
            [mobileHigh, mobileLow, desktopMP4, fallback, hls]
                .first(where: { $0?.isDownloadable == true })?
                .flatMap { $0 }
        case .low:
            [mobileLow, mobileHigh, desktopMP4, fallback, hls]
                .first(where: { $0?.isDownloadable == true })?
                .flatMap { $0 }
        }
    }

    public func video(streamingQuality: StreamingQuality) -> CourseBlockVideo? {
        switch streamingQuality {
        case .auto:
            [mobileLow, mobileHigh, desktopMP4, fallback, hls]
                .compactMap { $0 }
                .sorted(by: { ($0?.streamPriority ?? 0) < ($1?.streamPriority ?? 0) })
                .first?
                .flatMap { $0 }
        case .high:
            [desktopMP4, mobileHigh, mobileLow, fallback, hls]
                .compactMap { $0 }
                .first?
                .flatMap { $0 }
        case .medium:
            [mobileHigh, mobileLow, desktopMP4, fallback, hls]
                .compactMap { $0 }
                .first?
                .flatMap { $0 }
        case .low:
            [mobileLow, mobileHigh, desktopMP4, fallback, hls]
                .compactMap { $0 }
                .first(where: { $0?.isDownloadable == true })?
                .flatMap { $0 }
        }
    }

    public var youtubeVideoUrl: String? {
        youtube?.url
    }

}

public struct CourseBlockVideo: Equatable {
    public let url: String?
    public let fileSize: Int?
    public let streamPriority: Int?

    public init(url: String?, fileSize: Int?, streamPriority: Int?) {
        self.url = url
        self.fileSize = fileSize
        self.streamPriority = streamPriority
    }

    public var isVideoURL: Bool {
        [".mp4", ".m3u8"].contains(where: { url?.contains($0) == true })
    }

    public var isDownloadable: Bool {
        [".mp4"].contains(where: { url?.contains($0) == true })
    }
}
