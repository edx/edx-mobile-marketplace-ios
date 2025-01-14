//
//  NotificationsInteractor.swift
//  Notifications
//
//  Created by Saeed Bashir on 11.12.2024.
//

import Foundation
import Core

//sourcery: AutoMockable
public protocol NotificationsInteractorProtocol {
    func getNotificationsCount() async throws -> NotificationsCount
    func getNotificationsPreferences() async throws -> NotificationsPreferences
    func updateNotificationsPreferences(value: Bool) async throws -> NotificationsPreferencesUpdate
    func markNotificationsAsSeen() async throws -> NotificationsSeenRead
    func markNotificationAsRead(notificationId: String) async throws -> NotificationsSeenRead
    func markAllNotificationsAsRead() async throws -> NotificationsSeenRead
}

public class NotificationsInteractor: NotificationsInteractorProtocol {
    
    private let repository: NotificationsRepositoryProtocol
    
    public init(repository: NotificationsRepositoryProtocol) {
        self.repository = repository
    }
    
    public func getNotificationsCount() async throws -> NotificationsCount {
        try await repository.getNotificationsCount()
    }
    
    public func getNotificationsPreferences() async throws -> NotificationsPreferences {
        try await repository.getNotificationsPreferences()
    }
    
    public func updateNotificationsPreferences(value: Bool) async throws -> NotificationsPreferencesUpdate {
        try await repository.updateNotificationsPreferences(value: value)
    }
    
    public func markNotificationsAsSeen() async throws -> NotificationsSeenRead {
        try await repository.markNotificationsAsSeen()
    }
    
    public func markNotificationAsRead(notificationId: String) async throws -> NotificationsSeenRead {
        try await repository.markNotificationAsRead(notificationId: notificationId)
    }
    
    public func markAllNotificationsAsRead() async throws -> NotificationsSeenRead {
        try await repository.markAllNotificationsAsRead()
    }
}

// Mark - For testing and SwiftUI preview
#if DEBUG
public extension NotificationsInteractor {
    static let mock = NotificationsInteractor(repository: NotificationsRepositoryMock())
}
#endif
