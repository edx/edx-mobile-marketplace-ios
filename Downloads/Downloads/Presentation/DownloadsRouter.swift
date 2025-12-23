//
//  DownloadsRouter.swift
//  Downloads
//
//  Created by Ivan Stepanok on 28.02.2025.
//

import Foundation
import Core

@MainActor
public protocol DownloadsRouter: BaseRouter {
    // swiftlint:disable:next function_parameter_count
    func showCourseScreens(
        courseID: String,
        hasAccess: Bool?,
        courseStart: Date?,
        courseEnd: Date?,
        enrollmentStart: Date?,
        enrollmentEnd: Date?,
        title: String,
        org: String?,
        courseRawImage: String?,
        coursewareAccess: CoursewareAccess?,
        showDates: Bool,
        lastVisitedBlockID: String?
    )
    func showSettings()
}

// Mark - For testing and SwiftUI preview
#if DEBUG
public class DownloadsRouterMock: BaseRouterMock, DownloadsRouter {
    // swiftlint:disable:next function_parameter_count
    public func showCourseScreens(
        courseID: String,
        hasAccess: Bool?,
        courseStart: Date?,
        courseEnd: Date?,
        enrollmentStart: Date?,
        enrollmentEnd: Date?,
        title: String,
        org: String?,
        courseRawImage: String?,
        coursewareAccess: CoursewareAccess?,
        showDates: Bool,
        lastVisitedBlockID: String?
    ) {}
    public func showSettings() {}
}
#endif
