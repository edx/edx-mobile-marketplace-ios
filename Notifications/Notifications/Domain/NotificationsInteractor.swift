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
    
}

public class NotificationsInteractor: NotificationsInteractorProtocol {
    
    private let repository: NotificationsRepositoryProtocol
    
    public init(repository: NotificationsRepositoryProtocol) {
        self.repository = repository
    }
}

// Mark - For testing and SwiftUI preview
//#if DEBUG
//public extension NotificationsInteractor {
//    static let mock = NotificationsInteractor(repository: NotificationsRepositoryMock())
//}
//#endif
