//
//  Notifications.swift
//  Notifications
//
//  Created by Shafqat Muneer on 1/6/25.
//

import Foundation

public struct Notifications: Hashable {
    public let next: String?
    public let count: Int?
    public let numPages: Int?
    public let currentPage: Int?
    public let start: Int?
    public let results: [Notification]?
    
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

public struct Notification: Hashable {
    public let id: Int
    public let appName: String?
    public let notificationType: String?
    public let contentContext: ContentContext?
    public let content: String?
    public let courseId: String?
    public var lastRead: Date?
    public let lastSeen: Date?
    public let created: Date
    
    public init(
        id: Int,
        appName: String?,
        notificationType: String?,
        contentContext: ContentContext?,
        content: String?,
        courseId: String?,
        lastRead: Date?,
        lastSeen: Date?,
        created: Date
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
    
    var contentWithQuotes: String {
        guard let content = content,
              let postTitle = contentContext?.postTitle,
              content.contains(postTitle) else {
            return content ?? ""
        }
        return content.replacingOccurrences(of: postTitle, with: "\"\(postTitle)\"")
    }
}

public struct ContentContext: Hashable {
    public let topicId: String?
    public let parentId: String?
    public let threadId: String?
    public let commentId: String?
    public let postTitle: String?
    
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
