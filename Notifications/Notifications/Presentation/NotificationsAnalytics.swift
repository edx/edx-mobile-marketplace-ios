//
//  NotificationsAnalytics.swift
//  Notifications
//
//  Created by Saeed Bashir on 11.12.2024.
//

import Foundation
import Core

//sourcery: AutoMockable
public protocol NotificationsAnalytics {
    func notificationsScreenEvent(event: AnalyticsEvent, biValue: EventBIValue)
    func notificationsDiscussionPermissionToggleEvent(action: Bool)
    func notificationInbox()
    func notificationTapped(notificationType: String)
}

#if DEBUG
class NotificationsAnalyticsMock: NotificationsAnalytics {
    public func notificationsScreenEvent(event: AnalyticsEvent, biValue: EventBIValue) {}
    public func notificationsDiscussionPermissionToggleEvent(action: Bool) {}
    public func notificationInbox() {}
    public func notificationTapped(notificationType: String) {}
}
#endif
