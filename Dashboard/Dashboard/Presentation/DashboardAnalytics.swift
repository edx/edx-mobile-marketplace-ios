//
//  DashboardAnalytics.swift
//  Dashboard
//
//  Created by  Stepanok Ivan on 29.06.2023.
//

import Foundation

public enum PrimaryCourseCardAction: String {
    case card = "card"
    case pastAssignment = "past_assignment"
    case upcomingAssignment = "upcoming_assignment"
    case startCourse = "start_course"
    case resumeCourse = "resume_course"
    case upgradeValueProp = "upgrade_value_prop"
}

//sourcery: AutoMockable
public protocol DashboardAnalytics {
    func dashboardCourseClicked(courseID: String, courseName: String)
    func mainProgramsClicked()
    func mainCoursesClicked()
    func learnViewAllCoursesClicked()
    func learnViewAllCardClicked()
    func learnSecondaryCourseCardClicked(courseID: String)
    func learnPrimaryCourseCardClicked(courseID: String, action: PrimaryCourseCardAction, blockId: String)
    func myCoursesAllCoursesViewed()
    func myCoursesFilterClicked(filter: String)
    func myCoursesCourseCardClicked(courseID: String, filter: String)
}

#if DEBUG
class DashboardAnalyticsMock: DashboardAnalytics {
    public func dashboardCourseClicked(courseID: String, courseName: String) {}
    public func mainProgramsClicked() {}
    public func mainCoursesClicked() {}
    public func learnViewAllCoursesClicked() {}
    public func learnViewAllCardClicked() {}
    public func learnSecondaryCourseCardClicked(courseID: String) {}
    public func learnPrimaryCourseCardClicked(courseID: String, action: PrimaryCourseCardAction, blockId: String) {}
    public func myCoursesAllCoursesViewed() {}
    public func myCoursesFilterClicked(filter: String) {}
    public func myCoursesCourseCardClicked(courseID: String, filter: String) {}
}
#endif
