//
//  DashboardAnalytics.swift
//  Dashboard
//
//  Created by  Stepanok Ivan on 29.06.2023.
//

import Foundation

//sourcery: AutoMockable
public protocol DashboardAnalytics {
    func dashboardCourseClicked(courseID: String, courseName: String)
    func mainProgramsClicked()
    func mainCoursesClicked()
    func notificationBellClicked(unreadNotifications: Bool)
}

#if DEBUG
class DashboardAnalyticsMock: DashboardAnalytics {
    public func dashboardCourseClicked(courseID: String, courseName: String) {}
    public func mainProgramsClicked() {}
    public func mainCoursesClicked() {}
    public func notificationBellClicked(unreadNotifications: Bool) {}
}
#endif
