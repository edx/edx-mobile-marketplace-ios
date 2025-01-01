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
}
#endif
