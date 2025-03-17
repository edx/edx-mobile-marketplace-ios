//
//  DeepLink.swift
//  OpenEdX
//
//  Created by Anton Yarmolenka on 24/01/2024.
//

import Foundation
import Core

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

private enum DeepLinkKeys: String, RawStringExtractable {
    case courseID = "course_id"
    case pathID = "path_id"
    case screenName = "screen_name"
    case notificationType = "notification_type"
    case notificationID = "notification_id"
    case topicID = "topic_id"
    case threadID = "thread_id"
    case commentID = "comment_id"
    case responseID = "response_id"
    case componentID = "component_id"
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
    let responseID: String?
    let componentID: String?
    var type: DeepLinkType
    
    init(dictionary: [AnyHashable: Any]) {
        courseID = dictionary[DeepLinkKeys.courseID.rawValue] as? String
        screenName = dictionary[DeepLinkKeys.screenName.rawValue] as? String
        notificationID = dictionary[DeepLinkKeys.notificationID.rawValue] as? String
        notificationType = dictionary[DeepLinkKeys.notificationType.rawValue] as? String
        pathID = dictionary[DeepLinkKeys.pathID.rawValue] as? String
        topicID = dictionary[DeepLinkKeys.topicID.rawValue] as? String
        threadID = dictionary[DeepLinkKeys.threadID.rawValue] as? String
        commentID = dictionary[DeepLinkKeys.commentID.rawValue] as? String
        componentID = dictionary[DeepLinkKeys.componentID.rawValue] as? String
        responseID = dictionary[DeepLinkKeys.responseID.rawValue] as? String
        type = DeepLinkType(
            rawValue: screenName ?? DeepLinkType.none.rawValue
        ) ?? .none
    }
}
