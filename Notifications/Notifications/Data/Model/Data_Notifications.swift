//
//  Notifications.swift
//  Notifications
//
//  Created by Shafqat Muneer on 1/6/25.
//

import Foundation
import Core

public extension DataLayer {
    struct NotificationsCountResponse: Codable {
        public let countByAppName: NotificationsCount
        
        enum CodingKeys: String, CodingKey {
            case countByAppName = "count_by_app_name"
        }
        
        public init(
            countByAppName: NotificationsCount
        ) {
            self.countByAppName = countByAppName
        }
    }
    
    struct NotificationsCount: Codable {
        var discussion: Int
        
        enum CodingKeys: String, CodingKey {
            case discussion
        }
        
        public init(discussion: Int, updates: Int, grading: Int) {
            self.discussion = discussion
        }
    }
}

public extension DataLayer.NotificationsCountResponse {
    var domain: NotificationsCount {
        return NotificationsCount(
            discussion: countByAppName.discussion
        )
    }
}

public extension DataLayer {
    struct NotificationsPreferencesResponse: Codable {
        public let response: DiscussionPreferencesResponse
        
        enum CodingKeys: String, CodingKey {
            case response = "data"
        }
        
        public init(response: DiscussionPreferencesResponse) {
            self.response = response
        }
    }
    
    struct DiscussionPreferencesResponse: Codable {
        public let discussion: DiscussionPreferences
        
        enum CodingKeys: String, CodingKey {
            case discussion
        }
        
        public init(discussion: DiscussionPreferences) {
            self.discussion = discussion
        }
    }
    
    struct DiscussionPreferences: Codable {
        let enabled: Bool
        let notificationType: DiscussionNotificationsType
        
        enum CodingKeys: String, CodingKey {
            case enabled = "enabled"
            case notificationType = "notification_types"
        }
        
        init(
            enabled: Bool,
            notificationType: DiscussionNotificationsType
        ) {
            self.enabled = enabled
            self.notificationType = notificationType
        }
    }
    
    struct DiscussionNotificationsType: Codable {
        let core: DiscussionNotificationsTypeCore
        
        enum CodingKeys: String, CodingKey {
            case core
        }
        
        init(core: DiscussionNotificationsTypeCore) {
            self.core = core
        }
    }
        
    struct DiscussionNotificationsTypeCore: Codable {
        let push: Bool
        
        enum CodingKeys: String, CodingKey {
            case push
        }
        
        init(push: Bool) {
            self.push = push
        }
    }
}

public extension DataLayer.NotificationsPreferencesResponse {
    var domain: NotificationsPreferences {
        return NotificationsPreferences(
            discussionsEnabled: response.discussion.enabled,
            coreEnabled: response.discussion.notificationType.core.push
        )
    }
}

public extension DataLayer {
    struct NotificationsPreferencesUpdateResponse: Decodable {
        public let status: String
        public let response: NotificationsPreferencesUpdate
        
        enum CodingKeys: String, CodingKey {
            case status
            case response = "data"
        }
        
        public init(
            status: String,
            response: NotificationsPreferencesUpdate
        ) {
            self.status = status
            self.response = response
        }
    }
    
    struct NotificationsPreferencesUpdate: Decodable {
        public let updatedValue: Bool
        public let notificationType: String
        public let channel: String
        public let app: String
        
        enum CodingKeys: String, CodingKey {
            case updatedValue = "updated_value"
            case notificationType = "notification_type"
            case channel
            case app
        }
    }
}

public extension DataLayer.NotificationsPreferencesUpdateResponse {
    var domain: NotificationsPreferencesUpdate {
        return NotificationsPreferencesUpdate(
            status: status,
            updatedValue: response.updatedValue,
            notificationType: response.notificationType,
            channel: response.channel,
            app: response.app
        )
    }
}

public extension DataLayer {
    struct NotificationsSeenReadResponse: Decodable {
        let message: String
        
        enum CodingKeys: String, CodingKey {
            case message
        }
        
        public init(message: String) {
            self.message = message
        }
    }
}

public extension DataLayer.NotificationsSeenReadResponse {
    var domain: NotificationsSeenRead {
        return NotificationsSeenRead(message: message)
    }
}

public extension DataLayer {
    struct Notifications: Codable {
        public let next: String?
        public let count: Int?
        public let numPages: Int?
        public let currentPage: Int?
        public let start: Int?
        public let results: [Notification]?
        
        enum CodingKeys: String, CodingKey {
            case next
            case count
            case numPages = "num_pages"
            case currentPage = "current_page"
            case start
            case results
        }
        
        public init(
            next: String?,
            count: Int?,
            numPages: Int?,
            currentPage: Int?,
            start: Int?,
            results: [Notification]?
        ) {
            self.next = next
            self.count = count
            self.numPages = numPages
            self.currentPage = currentPage
            self.start = start
            self.results = results
        }
    }
    
    struct Notification: Codable {
        public let id: Int
        public let appName: String?
        public let notificationType: String?
        public let contentContext: ContentContext?
        public let content: String?
        public let courseId: String?
        public let lastRead: String?
        public let lastSeen: String?
        public let created: String
        
        enum CodingKeys: String, CodingKey {
            case id
            case appName = "app_name"
            case notificationType = "notification_type"
            case contentContext = "content_context"
            case content
            case courseId = "course_id"
            case lastRead = "last_read"
            case lastSeen = "last_seen"
            case created
        }
        
        public init(
            id: Int,
            appName: String?,
            notificationType: String?,
            contentContext: ContentContext?,
            content: String?,
            courseId: String?,
            lastRead: String?,
            lastSeen: String?,
            created: String
        ) {
            self.id = id
            self.appName = appName
            self.notificationType = notificationType
            self.contentContext = contentContext
            self.content = content
            self.courseId = courseId
            self.lastRead = lastRead
            self.lastSeen = lastSeen
            self.created = created
        }
    }
    
    struct ContentContext: Codable {
        public let topicId: String?
        public let parentId: String?
        public let threadId: String?
        public let commentId: String?
        public let postTitle: String?
        
        enum CodingKeys: String, CodingKey {
            case topicId = "topic_id"
            case parentId = "parent_id"
            case threadId = "thread_id"
            case commentId = "comment_id"
            case postTitle = "post_title"
        }
        
        public init(
            topicId: String?,
            parentId: String?,
            threadId: String?,
            commentId: String?,
            postTitle: String?
        ) {
            self.topicId = topicId
            self.parentId = parentId
            self.threadId = threadId
            self.commentId = commentId
            self.postTitle = postTitle
        }
    }
}

public extension DataLayer.Notifications {
    var domain: Notifications {
        Notifications(
            next: next,
            count: count,
            numPages: numPages,
            currentPage: currentPage,
            start: start,
            results: results?.compactMap { result in
                SingleNotification(
                    id: result.id,
                    appName: result.appName,
                    notificationType: result.notificationType,
                    contentContext: ContentContext(
                        topicId: result.contentContext?.topicId,
                        parentId: result.contentContext?.parentId,
                        threadId: result.contentContext?.threadId,
                        commentId: result.contentContext?.commentId,
                        postTitle: result.contentContext?.postTitle
                    ),
                    content: result.content,
                    courseId: result.courseId,
                    lastRead: result.lastRead.flatMap { Date(iso8601: $0) },
                    lastSeen: result.lastSeen.flatMap { Date(iso8601: $0) },
                    created: Date(iso8601: result.created)
                )
            }
        )
    }
}
