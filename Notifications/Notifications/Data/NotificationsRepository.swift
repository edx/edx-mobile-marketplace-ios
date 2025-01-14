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

public protocol NotificationsRepositoryProtocol {
    func getNotificationsCount() async throws -> NotificationsCount
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
