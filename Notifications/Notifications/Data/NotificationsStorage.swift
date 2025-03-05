//
//  NotificationsStorage.swift
//  Notifications
//
//  Created by Muhammad Tayyab Akram on 2/19/25.
//

import Foundation

public protocol NotificationsStorage: AnyObject {
    var notificationsPrimerDismissalCount: Int { get set }
    var notificationsPrimerLastShownDate: Date? { get set }
}

#if DEBUG
public class NotificationsStorageMock: NotificationsStorage {
    public var notificationsPrimerDismissalCount: Int = 0
    public var notificationsPrimerLastShownDate: Date?
    
    public init() {}
}
#endif
