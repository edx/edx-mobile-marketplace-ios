//
//  DeepLink.swift
//  OpenEdX
//
//  Created by Anton Yarmolenka on 24/01/2024.
//

import Foundation

enum DeepLinkType: String {
    case courseDashboard = "course_dashboard"
    case courseVideos = "course_videos"
    case discussions = "course_discussion"
    case courseDates = "course_dates"
    case courseHandout = "course_handout"
    case courseComponent = "course_component"
    case courseAnnouncement = "course_announcement"
    case discussionTopic = "discussion_topic"
    case discussionPost = "discussion_post"
    case discussionComment = "discussion_comment"
    case discovery = "discovery"
    case discoveryCourseDetail = "discovery_course_detail"
    case discoveryProgramDetail = "discovery_program_detail"
    case program = "program"
    case programDetail = "program_detail"
    case userProfile = "user_profile"
    case profile = "profile"
    case forumResponse = "forum_response"
    case forumComment = "forum_comment"
    case enroll = "enroll"
    case unenroll = "unenroll"
    case addBetaTester = "add_beta_tester"
    case removeBetaTester = "remove_beta_tester"
    case none
}

public class DeepLink {
    let courseID: String?
    let screenName: String?
    let notificationID: String?
    let notificationType: String?
    let pathID: String?
    let topicID: String?
    let threadID: String?
    let commentID: String?
    let parentID: String?
    let componentID: String?
    var type: DeepLinkType
    
    init(dictionary: [AnyHashable: Any]) {
        let payload = Payload(dictionary: dictionary)
        courseID = payload[.courseID]
        screenName = payload[.screenName]
        notificationID = payload[.notificationID]
        notificationType = payload[.notificationType]
        pathID = payload[.pathID]
        topicID = payload[.topicID]
        threadID = payload[.threadID]
        commentID = payload[.commentID]
        componentID = payload[.componentID]
        parentID = payload[.parentID]
        type = DeepLinkType(
            rawValue: screenName ?? notificationType ?? DeepLinkType.none.rawValue
        ) ?? .none
    }
}
