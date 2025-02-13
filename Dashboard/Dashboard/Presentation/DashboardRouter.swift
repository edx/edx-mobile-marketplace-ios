//
//  DashboardRouter.swift
//  Dashboard
//
//  Created by  Stepanok Ivan on 16.11.2022.
//

import Foundation
import Core

@MainActor
public protocol DashboardRouter: BaseRouter {
    // swiftlint:disable:next function_parameter_count
    func showCourseScreens(courseID: String,
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
    
    func showAllCourses(courses: [CourseItem])
    
    func showDiscoverySearch(searchQuery: String?)
    
    func showSettings()
    
    func showNotificationsScreen()
}

// Mark - For testing and SwiftUI preview
#if DEBUG
public class DashboardRouterMock: BaseRouterMock, DashboardRouter {
    public override init() {}
    
    // swiftlint:disable:next function_parameter_count
    public func showCourseScreens(courseID: String,
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
                                  lastVisitedBlockID: String?) {}
    
    public func showAllCourses(courses: [CourseItem]) {}
    
    public func showDiscoverySearch(searchQuery: String?) {}
    
    public func showSettings() {}
    
    public func showNotificationsScreen() {}
}
#endif
