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
    func getAllNotifications(page: Int) async throws -> Notifications
}

public class NotificationsInteractor: NotificationsInteractorProtocol {
    
    private let repository: NotificationsRepositoryProtocol
    
    public init(repository: NotificationsRepositoryProtocol) {
        self.repository = repository
    }
    
    public func getNotificationsCount() async throws -> NotificationsCount {
        try await repository.getNotificationsCount()
    }
    
    public func getAllNotifications(page: Int) async throws -> Notifications {
        try await repository.getAllNotifications(page: page)
    }
}

// Mark - For testing and SwiftUI preview
#if DEBUG
public extension NotificationsInteractor {
    static let mock = NotificationsInteractor(repository: NotificationsRepositoryMock())
}
#endif
