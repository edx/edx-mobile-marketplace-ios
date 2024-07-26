//
//  AnalyticsManager.swift
//  OpenEdX
//
//  Created by  Stepanok Ivan on 27.06.2023.
//

import Foundation
import Core
import Authorization
import Discovery
import Dashboard
import Profile
import Course
import Discussion
import WhatsNew
import Swinject

// swiftlint:disable file_length type_body_length
protocol AnalyticsService {
    func identify(id: String, username: String?, email: String?)
    func logEvent(_ event: AnalyticsEvent, parameters: [String: Any]?)
    func logScreenEvent(_ event: AnalyticsEvent, parameters: [String: Any]?)
}

// swiftlint:disable type_body_length file_length
class AnalyticsManager: AuthorizationAnalytics,
                        MainScreenAnalytics,
                        DiscoveryAnalytics,
                        DashboardAnalytics,
                        ProfileAnalytics,
                        CourseAnalytics,
                        DiscussionAnalytics,
                        CoreAnalytics,
                        WhatsNewAnalytics {
    
    private var services: [AnalyticsService] = []
    
    // Init Analytics Manager
    public init(config: ConfigProtocol) {
        services = servicesFor(config: config)
    }

    private func servicesFor(config: ConfigProtocol) -> [AnalyticsService] {
        var analyticsServices: [AnalyticsService] = []
        // add Firebase Analytics Service
        if config.firebase.enabled && config.firebase.isAnalyticsSourceFirebase,
           let firebaseService = Container.shared.resolve(FirebaseAnalyticsService.self) {
            analyticsServices.append(firebaseService)
        }
        
        // add Segment Analytics Service
        if config.segment.enabled,
           let segmentService = Container.shared.resolve(SegmentAnalyticsService.self) {
            analyticsServices.append(segmentService)
        }
        
        if config.fullStory.enabled,
           let fullStoryService = Container.shared.resolve(FullStoryAnalyticsService.self) {
            analyticsServices.append(fullStoryService)
        }
        
        return analyticsServices
    }
    
    public func identify(id: String, username: String, email: String) {
        for service in services {
            service.identify(id: id, username: username, email: email)
        }
    }
    
    private func logEvent(_ event: AnalyticsEvent, parameters: [String: Any]? = nil) {
        for service in services {
            service.logEvent(event, parameters: parameters)
        }
    }
    
    private func logScreenEvent(_ event: AnalyticsEvent, parameters: [String: Any]? = nil) {
        for service in services {
            service.logScreenEvent(event, parameters: parameters)
        }
    }
    
    // MARK: Generic event tracker functions
    public func trackEvent(_ event: AnalyticsEvent, parameters: [String: Any]? = nil) {
        logEvent(event, parameters: parameters)
    }
    
    public func trackEvent(_ event: AnalyticsEvent, biValue: EventBIValue, parameters: [String: Any]?) {
        var eventParams: [String: Any] = [EventParamKey.name: biValue.rawValue]
        
        if let parameters {
            eventParams.merge(parameters, uniquingKeysWith: { (first, _) in first })
        }
        
        logEvent(event, parameters: eventParams)
    }
    
    private func trackEvent(_ event: AnalyticsEvent, biValue: EventBIValue) {
        logEvent(event, parameters: [EventParamKey.name: biValue.rawValue])
    }
    
    public func trackScreenEvent(_ event: AnalyticsEvent, parameters: [String: Any]? = nil) {
        logScreenEvent(event, parameters: parameters)
    }
    
    public func trackScreenEvent(_ event: AnalyticsEvent, biValue: EventBIValue, parameters: [String: Any]?) {
        var eventParams: [String: Any] = [EventParamKey.name: biValue.rawValue]
        
        if let parameters {
            eventParams.merge(parameters, uniquingKeysWith: { (first, _) in first })
        }
        
        logScreenEvent(event, parameters: eventParams)
    }
    
    private func trackScreenEvent(_ event: AnalyticsEvent, biValue: EventBIValue) {
        logScreenEvent(event, parameters: [EventParamKey.name: biValue.rawValue])
    }
    
    // MARK: Pre Login
    
    public func userLogin(method: AuthMethod) {
        logEvent(.userLogin, parameters: [EventParamKey.method: method.analyticsValue])
    }
    
    public func registerClicked() {
        trackEvent(.registerClicked, biValue: .registerClicked)
    }
    
    public func signInClicked() {
        trackEvent(.signInClicked, biValue: .signInClicked)
    }
    
    public func userSignInClicked() {
        trackEvent(.userSignInClicked, biValue: .userSignInClicked)
    }
    
    public func createAccountClicked() {
        trackEvent(.createAccountClicked, biValue: .createAccountClicked)
    }
    
    public func registrationSuccess(method: String) {
        let parameters = [
            EventParamKey.method: method,
            EventParamKey.name: EventBIValue.registrationSuccess.rawValue
        ]
        logEvent(.registrationSuccess, parameters: parameters)
    }
    
    public func forgotPasswordClicked() {
        trackEvent(.forgotPasswordClicked, biValue: .forgotPasswordClicked)
    }
    
    public func resetPasswordClicked() {
        trackEvent(.resetPasswordClicked, biValue: .resetPasswordClicked)
    }
    
    public func resetPassword(success: Bool) {
        trackEvent(
            .resetPasswordSuccess,
            biValue: .resetPasswordSuccess,
            parameters: [EventParamKey.success: success]
        )
    }
    
    public func authTrackScreenEvent(_ event: AnalyticsEvent, biValue: EventBIValue) {
        trackScreenEvent(event, biValue: biValue)
    }
    
    // MARK: MainScreenAnalytics
    
    public func mainDiscoveryTabClicked() {
        trackScreenEvent(.mainDiscoveryTabClicked, biValue: .mainDiscoveryTabClicked)
    }
    
    public func mainDashboardTabClicked() {
        trackEvent(.mainDashboardTabClicked, biValue: .mainDashboardTabClicked)
    }
    
    public func mainProgramsTabClicked() {
        trackScreenEvent(.mainProgramsTabClicked, biValue: .mainProgramsTabClicked)
    }
    
    public func mainProfileTabClicked() {
        trackScreenEvent(.mainProfileTabClicked, biValue: .mainProfileTabClicked)
    }
    
    // MARK: Discovery
    
    public func discoverySearchBarClicked() {
        trackEvent(.discoverySearchBarClicked, biValue: .discoverySearchBarClicked)
    }
    
    public func discoveryCoursesSearch(label: String, coursesCount: Int) {
        let parameters: [String: Any] = [EventParamKey.label: label,
                          EventParamKey.coursesCount: coursesCount,
                          EventParamKey.name: EventBIValue.discoveryCoursesSearch.rawValue]
        logEvent(.discoveryCoursesSearch, parameters: parameters)
    }
    
    public func discoveryCourseClicked(courseID: String, courseName: String) {
        let parameters = [
            EventParamKey.courseID: courseID,
            EventParamKey.courseName: courseName,
            EventParamKey.name: EventBIValue.discoveryCourseClicked.rawValue
        ]
        logEvent(.discoveryCourseClicked, parameters: parameters)
    }
    
    // MARK: Dashboard
    
    public func dashboardCourseClicked(courseID: String, courseName: String) {
        let parameters = [
            EventParamKey.courseID: courseID,
            EventParamKey.courseName: courseName,
            EventParamKey.name: EventBIValue.dashboardCourseClicked.rawValue
        ]
        logScreenEvent(.dashboardCourseClicked, parameters: parameters)
    }
    
    // MARK: Profile
    
    public func profileEditClicked() {
        let parameters = [
            EventParamKey.name: EventBIValue.profileEditClicked.rawValue,
            EventParamKey.category: EventCategory.profile
        ]
        
        logEvent(.profileEditClicked, parameters: parameters)
    }
    
    public func profileSwitch(action: String) {
        let parameters = [
            EventParamKey.action: action,
            EventParamKey.category: EventCategory.profile
        ]
        
        trackEvent(.profileWifiToggle, biValue: .profileWifiToggle, parameters: parameters)
    }
    
    public func profileWifiToggle(action: String) {
        let parameters = [
            EventParamKey.action: action,
            EventParamKey.category: EventCategory.profile
        ]
        
        trackEvent(.profileSwitch, biValue: .profileSwitch, parameters: parameters)
    }
    
    public func profileEditDoneClicked() {
        let parameters = [
            EventParamKey.name: EventBIValue.profileEditDoneClicked.rawValue,
            EventParamKey.category: EventCategory.profile
        ]
        logEvent(.profileEditDoneClicked, parameters: parameters)
    }
    
    public func profileDeleteAccountClicked() {
        let parameters = [
            EventParamKey.name: EventBIValue.profileDeleteAccountClicked.rawValue,
            EventParamKey.category: EventCategory.profile
        ]
        logEvent(.profileDeleteAccountClicked, parameters: parameters)
    }
    
    public func profileVideoSettingsClicked() {
        let parameters = [
            EventParamKey.name: EventBIValue.profileVideoSettingsClicked.rawValue,
            EventParamKey.category: EventCategory.profile
        ]
        logEvent(.profileVideoSettingsClicked, parameters: parameters)
    }
    
    public func profileUserDeleteAccountClicked() {
        trackEvent(
            .profileUserDeleteAccountClicked,
            biValue: .profileUserDeleteAccountClicked,
            parameters: [EventParamKey.category: EventCategory.profile]
        )
    }
    
    public func profileDeleteAccountSuccess(success: Bool) {
        trackEvent(
            .profileUserDeleteAccountClicked,
            biValue: .profileUserDeleteAccountClicked,
            parameters: [
                EventParamKey.category: EventCategory.profile,
                EventParamKey.success: success
            ]
        )
    }
    
    public func videoQualityChanged(
        _ event: AnalyticsEvent,
        bivalue: EventBIValue,
        value: String,
        oldValue: String
    ) {
        let parameters = [
            EventParamKey.name: bivalue.rawValue,
            EventParamKey.category: EventCategory.video,
            EventParamKey.value: value,
            EventParamKey.oldValue: oldValue
        ]
        
        logEvent(event, parameters: parameters)
    }
    
    public func profileTrackEvent(_ event: AnalyticsEvent, biValue: EventBIValue) {
        let parameters = [
            EventParamKey.category: EventCategory.profile,
            EventParamKey.name: biValue.rawValue
        ]
        
        logEvent(event, parameters: parameters)
    }
    
    public func profileScreenEvent(_ event: AnalyticsEvent, biValue: EventBIValue) {
        let parameters = [
            EventParamKey.category: EventCategory.profile,
            EventParamKey.name: biValue.rawValue
        ]
        
        logScreenEvent(event, parameters: parameters)
    }
    
    public func privacyPolicyClicked() {
        let parameters = [
            EventParamKey.name: EventBIValue.privacyPolicyClicked.rawValue,
            EventParamKey.category: EventCategory.profile
        ]
        logEvent(.privacyPolicyClicked, parameters: parameters)
    }
    
    public func cookiePolicyClicked() {
        let parameters = [
            EventParamKey.name: EventBIValue.cookiePolicyClicked.rawValue,
            EventParamKey.category: EventCategory.profile
        ]
        logEvent(.cookiePolicyClicked, parameters: parameters)
    }
    
    public func emailSupportClicked() {
        let parameters = [
            EventParamKey.name: EventBIValue.emailSupportClicked.rawValue,
            EventParamKey.category: EventCategory.profile
        ]
        logEvent(.emailSupportClicked, parameters: parameters)
    }
    
    public func faqClicked() {
        let parameters = [
            EventParamKey.name: EventBIValue.faqClicked.rawValue,
            EventParamKey.category: EventCategory.profile
        ]
        logEvent(.faqClicked, parameters: parameters)
    }
    
    public func tosClicked() {
        let parameters = [
            EventParamKey.name: EventBIValue.tosClicked.rawValue,
            EventParamKey.category: EventCategory.profile
        ]
        logEvent(.tosClicked, parameters: parameters)
    }
    
    public func dataSellClicked() {
        let parameters = [
            EventParamKey.name: EventBIValue.dataSellClicked.rawValue,
            EventParamKey.category: EventCategory.profile
        ]
        logEvent(.dataSellClicked, parameters: parameters)
    }
    
    public func userLogout(force: Bool) {
        let parameters: [String: Any] = [
            EventParamKey.name: EventBIValue.userLogout.rawValue,
            EventParamKey.category: EventCategory.profile,
            EventParamKey.force: "\(force)"
        ]
        logEvent(.userLogout, parameters: parameters)
    }
    
    // MARK: Course
    
    public func courseEnrollClicked(courseId: String, courseName: String) {
        let parameters = [
            EventParamKey.courseID: courseId,
            EventParamKey.courseName: courseName,
            EventParamKey.conversion: courseId,
            EventParamKey.category: EventCategory.discovery
        ]
        logEvent(.courseEnrollClicked, parameters: parameters)
    }
    
    public func courseEnrollSuccess(courseId: String, courseName: String) {
        let parameters = [
            EventParamKey.courseID: courseId,
            EventParamKey.courseName: courseName,
            EventParamKey.conversion: courseId,
            EventParamKey.category: EventCategory.discovery
        ]
        logEvent(.courseEnrollSuccess, parameters: parameters)
    }
    
    func externalLinkOpen(url: String, screen: String) {
        let parameters = [
            EventParamKey.url: url,
            EventParamKey.screenName: screen,
            EventParamKey.category: EventCategory.discovery,
            EventParamKey.name: EventBIValue.externalLinkOpenAlert.rawValue
        ]
        logEvent(.externalLinkOpenAlert, parameters: parameters)
    }
    
    func externalLinkOpenAction(url: String, screen: String, action: String) {
        let parameters = [
            EventParamKey.url: url,
            EventParamKey.screenName: screen,
            EventParamKey.alertAction: action,
            EventParamKey.category: EventCategory.discovery,
            EventParamKey.name: EventBIValue.externalLinkOpenAlertAction.rawValue
        ]
        logEvent(.externalLinkOpenAlertAction, parameters: parameters)
    }
    
    public func discoveryScreenEvent(event: AnalyticsEvent, biValue: EventBIValue) {
        let parameters = [
            EventParamKey.category: EventCategory.discovery,
            EventParamKey.name: biValue.rawValue
        ]
        
        logScreenEvent(event, parameters: parameters)
    }
    
    public func viewCourseClicked(courseId: String, courseName: String) {
        let parameters = [
            EventParamKey.courseID: courseId,
            EventParamKey.courseName: courseName,
            EventParamKey.category: EventCategory.discovery
        ]
        logScreenEvent(.viewCourseClicked, parameters: parameters)
    }
    
    public func resumeCourseClicked(courseId: String, courseName: String, blockId: String) {
        let parameters = [
            EventParamKey.courseID: courseId,
            EventParamKey.courseName: courseName,
            EventParamKey.blockID: blockId,
            EventParamKey.name: EventBIValue.resumeCourseClicked.rawValue
        ]
        logEvent(.resumeCourseClicked, parameters: parameters)
    }
    
    public func sequentialClicked(courseId: String, courseName: String, blockId: String, blockName: String) {
        let parameters = [
            EventParamKey.courseID: courseId,
            EventParamKey.courseName: courseName,
            EventParamKey.blockID: blockId,
            EventParamKey.blockName: blockName,
            EventParamKey.name: EventBIValue.sequentialClicked.rawValue
        ]
        logEvent(.sequentialClicked, parameters: parameters)
    }
    
    public func verticalClicked(courseId: String, courseName: String, blockId: String, blockName: String) {
        let parameters = [
            EventParamKey.courseID: courseId,
            EventParamKey.courseName: courseName,
            EventParamKey.blockID: blockId,
            EventParamKey.blockName: blockName
        ]
        logEvent(.verticalClicked, parameters: parameters)
    }
    
    public func nextBlockClicked(courseId: String, courseName: String, blockId: String, blockName: String) {
        let parameters = [
            EventParamKey.courseID: courseId,
            EventParamKey.courseName: courseName,
            EventParamKey.blockID: blockId,
            EventParamKey.blockName: blockName,
            EventParamKey.name: EventBIValue.nextBlockClicked.rawValue
        ]
        logEvent(.nextBlockClicked, parameters: parameters)
    }
    
    public func prevBlockClicked(courseId: String, courseName: String, blockId: String, blockName: String) {
        let parameters = [
            EventParamKey.courseID: courseId,
            EventParamKey.courseName: courseName,
            EventParamKey.blockID: blockId,
            EventParamKey.blockName: blockName,
            EventParamKey.name: EventBIValue.prevBlockClicked.rawValue
        ]
        logEvent(.prevBlockClicked, parameters: parameters)
    }
    
    public func finishVerticalClicked(courseId: String, courseName: String, blockId: String, blockName: String) {
        let parameters = [
            EventParamKey.courseID: courseId,
            EventParamKey.courseName: courseName,
            EventParamKey.blockID: blockId,
            EventParamKey.blockName: blockName,
            EventParamKey.name: EventBIValue.finishVerticalClicked.rawValue
        ]
        logEvent(.finishVerticalClicked, parameters: parameters)
    }
    
    public func finishVerticalNextSectionClicked(
        courseId: String,
        courseName: String,
        blockId: String,
        blockName: String
    ) {
        let parameters = [
            EventParamKey.courseID: courseId,
            EventParamKey.courseName: courseName,
            EventParamKey.blockID: blockId,
            EventParamKey.blockName: blockName,
            EventParamKey.name: EventBIValue.finishVerticalNextSectionClicked.rawValue
        ]
        logEvent(.finishVerticalNextSectionClicked, parameters: parameters)
    }
    
    public func finishVerticalBackToOutlineClicked(courseId: String, courseName: String) {
        let parameters = [
            EventParamKey.courseID: courseId,
            EventParamKey.courseName: courseName,
            EventParamKey.name: EventBIValue.finishVerticalBackToOutlineClicked.rawValue
        ]
        logEvent(.finishVerticalBackToOutlineClicked, parameters: parameters)
    }
    
    public func courseOutlineCourseTabClicked(courseId: String, courseName: String) {
        let parameters = [
            EventParamKey.courseID: courseId,
            EventParamKey.courseName: courseName,
            EventParamKey.name: EventBIValue.courseOutlineCourseTabClicked.rawValue
        ]
        logScreenEvent(.courseOutlineCourseTabClicked, parameters: parameters)
    }
    
    public func courseOutlineVideosTabClicked(courseId: String, courseName: String) {
        let parameters = [
            EventParamKey.courseID: courseId,
            EventParamKey.courseName: courseName,
            EventParamKey.name: EventBIValue.courseOutlineVideosTabClicked.rawValue
        ]
        logScreenEvent(.courseOutlineVideosTabClicked, parameters: parameters)
    }
    
    public func courseOutlineDatesTabClicked(courseId: String, courseName: String) {
        let parameters = [
            EventParamKey.courseID: courseId,
            EventParamKey.courseName: courseName,
            EventParamKey.name: EventBIValue.courseOutlineDatesTabClicked.rawValue
        ]
        logScreenEvent(.courseOutlineDatesTabClicked, parameters: parameters)
    }
    
    public func courseOutlineDiscussionTabClicked(courseId: String, courseName: String) {
        let parameters = [
            EventParamKey.courseID: courseId,
            EventParamKey.courseName: courseName,
            EventParamKey.name: EventBIValue.courseOutlineDiscussionTabClicked.rawValue
        ]
        logScreenEvent(.courseOutlineDiscussionTabClicked, parameters: parameters)
    }
    
    public func courseOutlineHandoutsTabClicked(courseId: String, courseName: String) {
        let parameters = [
            EventParamKey.courseID: courseId,
            EventParamKey.courseName: courseName,
            EventParamKey.name: EventBIValue.courseOutlineHandoutsTabClicked.rawValue
        ]
        logScreenEvent(.courseOutlineHandoutsTabClicked, parameters: parameters)
    }
    
    func datesComponentTapped(
        courseId: String,
        blockId: String,
        link: String,
        supported: Bool
    ) {
        let parameters: [String: Any] = [
            EventParamKey.courseID: courseId,
            EventParamKey.blockID: blockId,
            EventParamKey.link: link,
            EventParamKey.supported: supported,
            EventParamKey.category: EventCategory.courseDates,
            EventParamKey.name: EventBIValue.datesComponentClicked.rawValue
        ]
        
        logEvent(.datesComponentClicked, parameters: parameters)
    }
    
    func calendarSyncToggle(
        enrollmentMode: EnrollmentMode,
        pacing: CoursePacing,
        courseId: String,
        action: CalendarDialogueAction
    ) {
        let parameters: [String: Any] = [
            EventParamKey.enrollmentMode: enrollmentMode.rawValue,
            EventParamKey.pacing: pacing.rawValue,
            EventParamKey.courseID: courseId,
            EventParamKey.action: action.rawValue,
            EventParamKey.category: EventCategory.courseDates,
            EventParamKey.name: EventBIValue.datesCalendarSyncToggle.rawValue
        ]
        
        logEvent(.datesCalendarSyncToggle, parameters: parameters)
    }
    
    func calendarSyncDialogAction(
        enrollmentMode: EnrollmentMode,
        pacing: CoursePacing,
        courseId: String,
        dialog: CalendarDialogueType,
        action: CalendarDialogueAction
    ) {
        let parameters: [String: Any] = [
            EventParamKey.enrollmentMode: enrollmentMode.rawValue,
            EventParamKey.pacing: pacing.rawValue,
            EventParamKey.courseID: courseId,
            EventParamKey.dialog: dialog.rawValue,
            EventParamKey.action: action.rawValue,
            EventParamKey.category: EventCategory.courseDates,
            EventParamKey.name: EventBIValue.datesCalendarSyncDialogAction.rawValue
        ]
        
        logEvent(.datesCalendarSyncDialogAction, parameters: parameters)
    }
    
    func calendarSyncSnackbar(
        enrollmentMode: EnrollmentMode,
        pacing: CoursePacing,
        courseId: String,
        snackbar: SnackbarType
    ) {
        let parameters: [String: Any] = [
            EventParamKey.enrollmentMode: enrollmentMode.rawValue,
            EventParamKey.pacing: pacing.rawValue,
            EventParamKey.courseID: courseId,
            EventParamKey.snackbar: snackbar.rawValue,
            EventParamKey.category: EventCategory.courseDates,
            EventParamKey.name: EventBIValue.datesCalendarSyncSnackbar.rawValue
        ]
        
        logEvent(.datesCalendarSyncSnackbar, parameters: parameters)
    }
    
    public func trackCourseEvent(_ event: AnalyticsEvent, biValue: EventBIValue, courseID: String) {
        let parameters = [
            EventParamKey.courseID: courseID,
            EventParamKey.category: EventCategory.course,
            EventParamKey.name: biValue.rawValue
        ]
        
        logEvent(event, parameters: parameters)
    }
    
    public func trackCourseScreenEvent(_ event: AnalyticsEvent, biValue: EventBIValue, courseID: String) {
        let parameters = [
            EventParamKey.courseID: courseID,
            EventParamKey.category: EventCategory.course,
            EventParamKey.name: biValue.rawValue
        ]
        
        logScreenEvent(event, parameters: parameters)
    }
    
    public func plsEvent(
        _ event: AnalyticsEvent,
        bivalue: EventBIValue,
        courseID: String,
        screenName: String,
        type: String
    ) {
        let parameters = [
            EventParamKey.courseID: courseID,
            EventParamKey.name: bivalue.rawValue,
            EventParamKey.screenName: screenName,
            EventParamKey.bannerType: type
        ]
        
        logEvent(event, parameters: parameters)
    }
    
    public func plsSuccessEvent(
        _ event: AnalyticsEvent,
        bivalue: EventBIValue,
        courseID: String,
        screenName: String,
        type: String,
        success: Bool
    ) {
        let parameters: [String: Any] = [
            EventParamKey.courseID: courseID,
            EventParamKey.name: bivalue.rawValue,
            EventParamKey.screenName: screenName,
            EventParamKey.bannerType: type,
            EventParamKey.success: success
        ]
        
        logEvent(event, parameters: parameters)
    }
    
    public func bulkDownloadVideosToggle(courseID: String, action: Bool) {
        let parameters: [String: Any] = [
            EventParamKey.courseID: courseID,
            EventParamKey.action: action,
            EventParamKey.category: EventCategory.video,
            EventParamKey.name: EventBIValue.bulkDownloadVideosToggle.rawValue
        ]
        
        logEvent(.bulkDownloadVideosToggle, parameters: parameters)
    }
    
    public func bulkDownloadVideosSubsection(
        courseID: String,
        sectionID: String,
        subSectionID: String,
        videos: Int
    ) {
        let parameters: [String: Any] = [
            EventParamKey.courseID: courseID,
            EventParamKey.courseSection: sectionID,
            EventParamKey.courseSubsection: subSectionID,
            EventParamKey.noOfVideos: videos,
            EventParamKey.category: EventCategory.video,
            EventParamKey.name: EventBIValue.bulkDownloadVideosSubsection.rawValue
        ]
        
        logEvent(.bulkDownloadVideosSubsection, parameters: parameters)
    }
    
    public func bulkDownloadVideosSection(
        courseID: String,
        sectionID: String,
        videos: Int
    ) {
        let parameters: [String: Any] = [
            EventParamKey.courseID: courseID,
            EventParamKey.courseSection: sectionID,
            EventParamKey.noOfVideos: videos,
            EventParamKey.category: EventCategory.video,
            EventParamKey.name: EventBIValue.bulkDownloadVideosSection.rawValue
        ]
        
        logEvent(.bulkDownloadVideosSection, parameters: parameters)
    }
    
    public func bulkDeleteVideosSubsection(
        courseID: String,
        subSectionID: String,
        videos: Int
    ) {
        let parameters: [String: Any] = [
            EventParamKey.courseID: courseID,
            EventParamKey.courseSubsection: subSectionID,
            EventParamKey.noOfVideos: videos,
            EventParamKey.category: EventCategory.video,
            EventParamKey.name: EventBIValue.bulkDeleteVideosSubsection.rawValue
        ]
        
        logEvent(.bulkDeleteVideosSubsection, parameters: parameters)
    }
    
    public func bulkDeleteVideosSection(
        courseID: String,
        sectionId: String,
        videos: Int
    ) {
        let parameters: [String: Any] = [
            EventParamKey.courseID: courseID,
            EventParamKey.courseSection: sectionId,
            EventParamKey.noOfVideos: videos,
            EventParamKey.category: EventCategory.video,
            EventParamKey.name: EventBIValue.bulkDeleteVideosSection.rawValue
        ]
        
        logEvent(.bulkDeleteVideosSection, parameters: parameters)
    }
    
    // MARK: Discussion
    public func discussionAllPostsClicked(courseId: String, courseName: String) {
        let parameters = [
            EventParamKey.courseID: courseId,
            EventParamKey.courseName: courseName,
            EventParamKey.name: EventBIValue.discussionAllPostsClicked.rawValue
        ]
        logEvent(.discussionAllPostsClicked, parameters: parameters)
    }
    
    public func discussionFollowingClicked(courseId: String, courseName: String) {
        let parameters = [
            EventParamKey.courseID: courseId,
            EventParamKey.courseName: courseName,
            EventParamKey.name: EventBIValue.discussionFollowingClicked.rawValue
        ]
        logEvent(.discussionFollowingClicked, parameters: parameters)
    }
    
    public func discussionTopicClicked(courseId: String, courseName: String, topicId: String, topicName: String) {
        let parameters = [
            EventParamKey.courseID: courseId,
            EventParamKey.courseName: courseName,
            EventParamKey.topicID: topicId,
            EventParamKey.topicName: topicName,
            EventParamKey.name: EventBIValue.discussionTopicClicked.rawValue
        ]
        logEvent(.discussionTopicClicked, parameters: parameters)
    }
    
    // MARK: app review
    
    public func appreview(
        _ event: AnalyticsEvent,
        biValue: EventBIValue,
        action: String? = nil,
        rating: Int? = 0
    ) {
        var parameters: [String: Any] = [
            EventParamKey.category: EventCategory.appreviews,
            EventParamKey.name: biValue.rawValue
        ]
        
        if rating != 0 {
            parameters[EventParamKey.rating] = rating ?? 0
        }
        
        if let action {
            parameters[EventParamKey.action] = action
        }
        
        logEvent(event, parameters: parameters)
    }
    
    // MARK: whats new
    
    func whatsnewPopup() {
        let parameters = [
            EventParamKey.name: EventBIValue.whatnewPopup.rawValue,
            EventParamKey.category: EventCategory.whatsNew
        ]
        logEvent(.whatnewPopup, parameters: parameters)
    }
    
    func whatsnewDone(totalScreens: Int) {
        let parameters: [String: Any] = [
            EventParamKey.category: EventCategory.whatsNew,
            EventParamKey.name: EventBIValue.whatnewDone.rawValue,
            "total_screens": totalScreens
        ]
        
        logEvent(.whatnewDone, parameters: parameters)
    }
    
    func whatsnewClose(totalScreens: Int, currentScreen: Int) {
        let parameters: [String: Any] = [
            EventParamKey.category: EventCategory.whatsNew,
            EventParamKey.name: EventBIValue.whatnewClose.rawValue,
            "total_screens": totalScreens,
            "currently_viewed": currentScreen
        ]
        
        logEvent(.whatnewClose, parameters: parameters)
    }
    
    // MARK: Course Upgrade
    
    public func trackCourseUpgradePaymentError(
        _ event: AnalyticsEvent,
        biValue: EventBIValue,
        courseID: String,
        blockID: String?,
        pacing: String,
        localizedPrice: NSDecimalNumber?,
        localizedCurrencyCode: String?,
        lmsPrice: Double?,
        screen: CourseUpgradeScreen,
        error: String
    ) {
        var parameters: [String: Any] = [
            EventParamKey.pacing: pacing,
            EventParamKey.courseID: courseID,
            EventParamKey.screenName: screen.rawValue,
            EventParamKey.error: error,
            EventParamKey.category: EventCategory.inAppPurchases,
            EventParamKey.name: biValue.rawValue
        ]
        
        parameters.setObjectOrNil(localizedPrice, forKey: EventParamKey.localizedPrice)
        parameters.setObjectOrNil(localizedCurrencyCode, forKey: EventParamKey.localizedCurrencyCode)
        parameters.setObjectOrNil(lmsPrice, forKey: EventParamKey.lmsPrice)
        parameters.setObjectOrNil(blockID, forKey: EventParamKey.blockID)
        
        logEvent(event, parameters: parameters)
    }
    
    public func trackCourseUpgradeError(
        courseID: String,
        blockID: String?,
        pacing: String,
        localizedPrice: NSDecimalNumber?,
        localizedCurrencyCode: String?,
        lmsPrice: Double?,
        screen: CourseUpgradeScreen,
        error: String,
        flowType: UpgradeMode
    ) {
        var parameters: [String: Any] = [
            EventParamKey.pacing: pacing,
            EventParamKey.name: EventBIValue.courseUpgradeError.rawValue,
            EventParamKey.courseID: courseID,
            EventParamKey.screenName: screen.rawValue,
            EventParamKey.error: error,
            EventParamKey.flowType: flowType.rawValue,
            EventParamKey.category: EventCategory.inAppPurchases
        ]
        
        parameters.setObjectOrNil(blockID, forKey: EventParamKey.blockID)
        parameters.setObjectOrNil(localizedPrice, forKey: EventParamKey.localizedPrice)
        parameters.setObjectOrNil(localizedCurrencyCode, forKey: EventParamKey.localizedCurrencyCode)
        parameters.setObjectOrNil(lmsPrice, forKey: EventParamKey.lmsPrice)
        
        logEvent(.courseUpgradeError, parameters: parameters)
    }
    
    public func trackCourseUpgradeErrorAction(
        courseID: String,
        blockID: String?,
        pacing: String,
        localizedPrice: NSDecimalNumber?,
        localizedCurrencyCode: String?,
        lmsPrice: Double?,
        screen: CourseUpgradeScreen,
        alertType: UpgradeAlertType,
        errorAction: String,
        error: String,
        flowType: UpgradeMode
    ) {
        var parameters: [String: Any] = [
            EventParamKey.pacing: pacing,
            EventParamKey.name: EventBIValue.courseUpgradeErrorAction.rawValue,
            EventParamKey.courseID: courseID,
            EventParamKey.screenName: screen.rawValue,
            EventParamKey.error: error,
            EventParamKey.errorAction: errorAction,
            EventParamKey.flowType: flowType.rawValue,
            EventParamKey.category: EventCategory.inAppPurchases,
            EventParamKey.alertType: alertType.rawValue
        ]
        
        parameters.setObjectOrNil(blockID, forKey: EventParamKey.blockID)
        parameters.setObjectOrNil(localizedPrice, forKey: EventParamKey.localizedPrice)
        parameters.setObjectOrNil(localizedCurrencyCode, forKey: EventParamKey.localizedCurrencyCode)
        parameters.setObjectOrNil(lmsPrice, forKey: EventParamKey.lmsPrice)
        
        logEvent(.courseUpgradeErrorAction, parameters: parameters)
    }
    
    public func trackCourseUpgradeSuccess(
        courseID: String,
        blockID: String?,
        pacing: String,
        localizedPrice: NSDecimalNumber?,
        localizedCurrencyCode: String?,
        lmsPrice: Double?,
        screen: CourseUpgradeScreen,
        flowType: UpgradeMode
    ) {
        var parameters: [String: Any] = [
            EventParamKey.pacing: pacing,
            EventParamKey.name: EventBIValue.courseUpgradeSuccess.rawValue,
            EventParamKey.courseID: courseID,
            EventParamKey.screenName: screen.rawValue,
            EventParamKey.flowType: flowType.rawValue,
            EventParamKey.category: EventCategory.inAppPurchases
        ]
        
        parameters.setObjectOrNil(localizedPrice, forKey: EventParamKey.localizedPrice)
        parameters.setObjectOrNil(localizedCurrencyCode, forKey: EventParamKey.localizedCurrencyCode)
        parameters.setObjectOrNil(lmsPrice, forKey: EventParamKey.lmsPrice)
        parameters.setObjectOrNil(blockID, forKey: EventParamKey.blockID)
        
        logEvent(.courseUpgradeSuccess, parameters: parameters)
    }
    
    public func trackUpgradeNow(
        courseID: String,
        blockID: String?,
        pacing: String,
        screen: CourseUpgradeScreen,
        localizedPrice: NSDecimalNumber?,
        localizedCurrencyCode: String?,
        lmsPrice: Double?
    ) {
        var parameters: [String: Any] = [
            EventParamKey.pacing: pacing,
            EventParamKey.name: EventBIValue.upgradeNowClicked.rawValue,
            EventParamKey.courseID: courseID,
            EventParamKey.screenName: screen.rawValue,
            EventParamKey.category: EventCategory.inAppPurchases
        ]
        
        parameters.setObjectOrNil(localizedPrice, forKey: EventParamKey.localizedPrice)
        parameters.setObjectOrNil(localizedCurrencyCode, forKey: EventParamKey.localizedCurrencyCode)
        parameters.setObjectOrNil(lmsPrice, forKey: EventParamKey.lmsPrice)
        parameters.setObjectOrNil(blockID, forKey: EventParamKey.blockID)
        
        logEvent(.upgradeNowClicked, parameters: parameters)
    }
    
    public func trackCourseUpgradeLoadError(
        courseID: String,
        blockID: String? = nil,
        pacing: String,
        screen: CourseUpgradeScreen
    ) {
        var parameters: [String: Any] = [
            EventParamKey.pacing: pacing,
            EventParamKey.name: EventBIValue.courseUpgradePriceLoadError.rawValue,
            EventParamKey.courseID: courseID,
            EventParamKey.screenName: screen.rawValue,
            EventParamKey.category: EventCategory.inAppPurchases
        ]
        
        parameters.setObjectOrNil(blockID, forKey: EventParamKey.blockID)
        
        logEvent(.courseUpgradePriceLoadError, parameters: parameters)
    }
    
    public func trackCourseUnfulfilledPurchaseInitiated(
        courseID: String,
        pacing: String,
        screen: CourseUpgradeScreen,
        flowType: UpgradeMode
    ) {
        let parameters = [
            EventParamKey.pacing: pacing,
            EventParamKey.name: EventBIValue.courseUpgradeUnfulfilledPurchaseInitiated.rawValue,
            EventParamKey.courseID: courseID,
            EventParamKey.screenName: screen.rawValue,
            EventParamKey.flowType: flowType.rawValue,
            EventParamKey.category: EventCategory.inAppPurchases
        ]
        
        logEvent(.courseUpgradeUnfulfilledPurchaseInitiated, parameters: parameters)
    }
    
    public func trackRestorePurchaseClicked() {
        let parameters = [
            EventParamKey.name: EventBIValue.courseUpgradeRestorePurchaseClicked.rawValue,
            EventParamKey.category: EventCategory.inAppPurchases
        ]
        
        logEvent(.courseUpgradeRestorePurchaseClicked, parameters: parameters)
    }
}

// swiftlint:enable file_length type_body_length
