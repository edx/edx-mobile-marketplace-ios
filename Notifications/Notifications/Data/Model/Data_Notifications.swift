//
//  Notifications.swift
//  Notifications
//
//  Created by Shafqat Muneer on 1/6/25.
//

import Foundation
import Core

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
        public let id: Int?
        public let appName: String?
        public let notificationType: String?
        public let contentContext: ContentContext?
        public let content: String?
        public let lastRead: String?
        public let lastSeen: String?
        public let created: String
        
        enum CodingKeys: String, CodingKey {
            case id
            case appName = "app_name"
            case notificationType = "notification_type"
            case contentContext = "content_context"
            case content
            case lastRead = "last_read"
            case lastSeen = "last_seen"
            case created
        }
        
        public init(
            id: Int?,
            appName: String?,
            notificationType: String?,
            contentContext: ContentContext?,
            content: String?,
            lastRead: String?,
            lastSeen: String?,
            created: String
        ) {
            self.id = id
            self.appName = appName
            self.notificationType = notificationType
            self.contentContext = contentContext
            self.content = content
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
                Notification(
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
                    lastRead: result.lastRead.flatMap { Date(iso8601: $0) },
                    lastSeen: result.lastSeen.flatMap { Date(iso8601: $0) },
                    created: Date(iso8601: result.created)
                )
            }
        )
    }
}
