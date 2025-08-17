//
//  UserNotificationCenterProtocol.swift
//  Notifications
//
//  Created by Muhammad Tayyab  Akram on 8/12/25.
//

import UserNotifications

public protocol UserNotificationCenterProtocol: AnyObject {
    func authorizationStatus() async -> UNAuthorizationStatus
}

extension UNUserNotificationCenter: UserNotificationCenterProtocol {
    public func authorizationStatus() async -> UNAuthorizationStatus {
        let settings = await notificationSettings()
        return settings.authorizationStatus
    }
}

// Mark - For testing and SwiftUI preview
#if DEBUG
public final class UserNotificationCenterMock: UserNotificationCenterProtocol {
    public var authorizationStatus: UNAuthorizationStatus = .authorized

    public func authorizationStatus() async -> UNAuthorizationStatus {
        return authorizationStatus
    }
}
#endif
