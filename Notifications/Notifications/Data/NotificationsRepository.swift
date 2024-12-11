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
}

// Mark - For testing and SwiftUI preview
#if DEBUG
class NotificationsRepositoryMock: NotificationsRepositoryProtocol {
    
}
#endif
