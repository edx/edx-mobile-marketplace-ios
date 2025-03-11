//
//  NotificationsRepository.swift
//  Notifications
//
//  Created by Saeed Bashir on 11.12.2024.
//

import Foundation
import Core
import CoreData
import Alamofire
import OEXFoundation

public protocol NotificationsRepositoryProtocol {
    func getNotificationsCount() async throws -> NotificationsCount
    func getAllNotifications(page: Int) async throws -> Notifications
    func getNotificationsPreferences() async throws -> NotificationsPreferences
    func updateNotificationsPreferences(value: Bool) async throws -> NotificationsPreferencesUpdate
    func markNotificationsAsSeen() async throws -> NotificationsSeenRead
    func markNotificationAsRead(notificationId: String) async throws -> NotificationsSeenRead
    func markAllNotificationsAsRead() async throws -> NotificationsSeenRead
}

public class NotificationsRepository: NotificationsRepositoryProtocol {
    private let api: API
    private let coreStorage: CoreStorage
    private let config: ConfigProtocol
    private let persistence: NotificationsPersistenceProtocol
    
    public init(api: API,
                appStorage: CoreStorage,
                config: ConfigProtocol,
                persistence: NotificationsPersistenceProtocol) {
        self.api = api
        self.coreStorage = appStorage
        self.config = config
        self.persistence = persistence
    }
    
    public func getNotificationsCount() async throws -> NotificationsCount {
        let response = try await api.requestData(
            NotificationsEndpoint.getNotificationsCount
        ).mapResponse(DataLayer.NotificationsCountResponse.self)
            .domain
        
        return response

    }
    
    public func getAllNotifications(page: Int) async throws -> Notifications {
        let response = try await api.requestData(
            NotificationsEndpoint.getAllNotifications(page: page)
        ).mapResponse(DataLayer.Notifications.self).domain
        
        return response
    }
    
    public func getNotificationsPreferences() async throws -> NotificationsPreferences {
        let response = try await api.requestData(
            NotificationsEndpoint.getPreferences
        ).mapResponse(DataLayer.NotificationsPreferencesResponse.self)
            .domain
        
        return response
    }
    
    public func updateNotificationsPreferences(value: Bool) async throws -> NotificationsPreferencesUpdate {
        let response = try await api.requestData(
            NotificationsEndpoint.updatePreferences(value: value)
        ).mapResponse(DataLayer.NotificationsPreferencesUpdateResponse.self)
            .domain
        
        return response
    }
    
    public func markNotificationsAsSeen() async throws -> NotificationsSeenRead {
        let response = try await api.requestData(
            NotificationsEndpoint.markSeen
        ).mapResponse(DataLayer.NotificationsSeenReadResponse.self)
            .domain
        
        return response
    }
    
    public func markNotificationAsRead(notificationId: String) async throws -> NotificationsSeenRead {
        let response = try await api.requestData(
            NotificationsEndpoint.markRead(notificationId: notificationId)
        ).mapResponse(DataLayer.NotificationsSeenReadResponse.self)
            .domain
        
        return response
    }
    
    public func markAllNotificationsAsRead() async throws -> NotificationsSeenRead {
        let response = try await api.requestData(
            NotificationsEndpoint.markAllRead
        ).mapResponse(DataLayer.NotificationsSeenReadResponse.self)
            .domain
        
        return response
    }
}

// Mark - For testing and SwiftUI preview
#if DEBUG
class NotificationsRepositoryMock: NotificationsRepositoryProtocol {
    func getNotificationsCount() async throws -> NotificationsCount {
        return NotificationsCount(discussion: 1)
    }
    
    func getAllNotifications(page: Int) async throws -> Notifications {
        return Notifications(
            next: "",
            count: 18,
            numPages: 2,
            currentPage: 1,
            start: 0,
            results: [
                SingleNotification(
                    id: 123,
                    appName: "discussion",
                    notificationType: "comment_on_followed_post",
                    contentContext: ContentContext(
                        topicId: "i4x-edX-demoX1-course-2T2017",
                        parentId: "6777c03a7febe504707971ab",
                        threadId: "5d49c25584452a0795000386",
                        commentId: "677b2ffa7febe50470799585",
                        postTitle: "How to learn it online?"
                    ),
                    content: "Test notification",
                    courseId: "course-v1:edX+Test+2T2009",
                    lastRead: Date(iso8601: "2025-01-06T01:20:58.919612Z"),
                    lastSeen: Date(iso8601: "2025-01-06T01:20:58.919612Z"),
                    created: Date(iso8601: "2025-01-06T01:20:58.919612Z")
                )
            ])
    }
    
    func getNotificationsPreferences() async throws -> NotificationsPreferences {
        return NotificationsPreferences(
            discussionsEnabled: false,
            coreEnabled: false
        )
    }
    
    func updateNotificationsPreferences(value: Bool) async throws -> NotificationsPreferencesUpdate {
        return NotificationsPreferencesUpdate(
            status: "success",
            updatedValue: false,
            notificationType: "core",
            channel: "push",
            app: "discussion"
        )
    }
    
    func markNotificationsAsSeen() async throws -> NotificationsSeenRead {
        return NotificationsSeenRead(message: "success")
    }
    
    func markNotificationAsRead(notificationId: String) async throws -> NotificationsSeenRead {
        return NotificationsSeenRead(message: "success")
    }
    
    func markAllNotificationsAsRead() async throws -> NotificationsSeenRead {
        return NotificationsSeenRead(message: "success")
    }
}
#endif
