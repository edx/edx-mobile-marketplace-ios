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
    func NotificationsScreenEvent(event: AnalyticsEvent, biValue: EventBIValue)
}

#if DEBUG
class NotificationsAnalyticsMock: NotificationsAnalytics {
    public func NotificationsScreenEvent(event: AnalyticsEvent, biValue: EventBIValue) {}
}
#endif
