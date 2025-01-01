//
//  NotificationsResponse.swift
//  Notifications
//
//  Created by Saeed Bashir on 12/17/24.
//

public struct NotificationsCount {
    public var discussion: Int
    
    public init(discussion: Int) {
        self.discussion = discussion
    }
}

public struct NotificationsPreferences {
    public var discussionsEnabled: Bool
    public var coreEnabled: Bool
    
    public init(discussionsEnabled: Bool, coreEnabled: Bool) {
        self.discussionsEnabled = discussionsEnabled
        self.coreEnabled = coreEnabled
    }
}

public struct NotificationsPreferencesUpdate {
    public var status: String
    public var updatedValue: Bool
    public var notificationType: String
    public var channel: String
    public var app: String
    
    public init(
        status: String,
        updatedValue: Bool,
        notificationType: String,
        channel: String,
        app: String
    ) {
        self.status = status
        self.updatedValue = updatedValue
        self.notificationType = notificationType
        self.channel = channel
        self.app = app
    }
}
