//
//  NotificationsInteractor.swift
//  Notifications
//
//  Created by Saeed Bashir on 11.12.2024.
//

import Foundation
import UserNotifications
import Core

//sourcery: AutoMockable
public protocol NotificationsInteractorProtocol {
    func getNotificationsCount() async throws -> NotificationsCount
    func getAllNotifications(page: Int) async throws -> Notifications
    func getNotificationsPreferences() async throws -> NotificationsPreferences
    func updateNotificationsPreferences(value: Bool) async throws -> NotificationsPreferencesUpdate
    func markNotificationsAsSeen() async throws -> NotificationsSeenRead
    func markNotificationAsRead(notificationId: String) async throws -> NotificationsSeenRead
    func markAllNotificationsAsRead() async throws -> NotificationsSeenRead
    func shouldShowPrimer() async -> Bool
    func markPrimerAsShown()
}

public class NotificationsInteractor: NotificationsInteractorProtocol {
    private let repository: NotificationsRepositoryProtocol
    private let storage: NotificationsStorage
    
    private enum Constants {
        static let maxPrimerDismissalCount = 3
        static let primerPresentationWaitingDays: [Int: Int] = [
            1: 7,
            2: 30
        ]
    }
    
    public init(
        repository: NotificationsRepositoryProtocol,
        storage: NotificationsStorage
    ) {
        self.repository = repository
        self.storage = storage
    }
    
    public func getNotificationsCount() async throws -> NotificationsCount {
        try await repository.getNotificationsCount()
    }
    
    public func getAllNotifications(page: Int) async throws -> Notifications {
        try await repository.getAllNotifications(page: page)
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
    
    private func resetPrimerSettings() {
        storage.notificationsPrimerDismissalCount = 0
        storage.notificationsPrimerLastShownDate = nil
    }
    
    @MainActor
    public func shouldShowPrimer() async -> Bool {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        if settings.authorizationStatus == .authorized {
            resetPrimerSettings()
            return false
        }
        
        let dismissalCount = storage.notificationsPrimerDismissalCount
        if dismissalCount >= Constants.maxPrimerDismissalCount {
            return false
        }
        
        if let lastShownDate = storage.notificationsPrimerLastShownDate {
            if let waitingDays = Constants.primerPresentationWaitingDays[dismissalCount] {
                let now = Date()
                let limit = Calendar.current.date(
                    byAdding: .day,
                    value: waitingDays,
                    to: lastShownDate
                ) ?? now
                
                return now > limit
            }
            
            return false
        } else {
            return true
        }
    }
    
    public func markPrimerAsShown() {
        storage.notificationsPrimerDismissalCount += 1
        storage.notificationsPrimerLastShownDate = Date()
    }
}

// Mark - For testing and SwiftUI preview
#if DEBUG
public extension NotificationsInteractor {
    static let mock = NotificationsInteractor(
        repository: NotificationsRepositoryMock(),
        storage: NotificationsStorageMock()
    )
}
#endif
