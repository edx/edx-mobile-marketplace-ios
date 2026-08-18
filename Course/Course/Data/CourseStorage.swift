//
//  CourseStorage.swift
//  Course
//
//  Created by Eugene Yatsenko on 28.12.2023.
//

import Foundation
import Core

public enum CourseBannerType: String {
    case resetDates = "ResetDates"
    case upgradeToGraded = "UpgradeToGraded"
    case infoBanner = "InfoBanner"
    case upgradeToReset = "UpgradeToReset"
}

public protocol CourseStorage {
    var allowedDownloadLargeFile: Bool? { get set }
    var userSettings: UserSettings? { get set }

    func dismissalDate(for bannerType: CourseBannerType, courseID: String) -> Date?
    func setDismissalDate(for bannerType: CourseBannerType, courseID: String, to date: Date?)
    
    func isVerticalFinishNotified(courseID: String, verticalID: String) -> Bool
    func markVerticalFinishNotified(courseID: String, verticalID: String)
}

#if DEBUG
public class CourseStorageMock: CourseStorage {
    public func isVerticalFinishNotified(courseID: String, verticalID: String) -> Bool { false }
    
    public func markVerticalFinishNotified(courseID: String, verticalID: String) {}
    
    
    public var userSettings: UserSettings?

    public var allowedDownloadLargeFile: Bool?

    public init() {}

    public func dismissalDate(for bannerType: CourseBannerType, courseID: String) -> Date? { nil }

    public func setDismissalDate(for bannerType: CourseBannerType, courseID: String, to date: Date?) {}
}
#endif
