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
    func notificationScreenEvent(_ event: AnalyticsEvent, biValue: EventBIValue)
    func notificationDiscussionPreferenceToggle(action: Bool)
    func notificationPreferencesToggleBatchState(discussionsActivity: Bool)
    func notificationSystemPermissionDialogAction(action: String)
    func notificationAppPermissionRationaleDialogAction(action: String)
    func notificationInboxMenuClicked()
    func notificationMarkAllReadClicked()
    func notificationPushNotificationsSettingClicked()
    func notificationInboxItemClicked(
        notificationDomain: String,
        notificationType: String,
        notificationID: String,
        courseID: String?,
        topicID: String?,
        threadID: String?,
        responseID: String?,
        commentID: String?
    )
}

#if DEBUG
final class NotificationsAnalyticsMock: NotificationsAnalytics {
    func notificationScreenEvent(_ event: AnalyticsEvent, biValue: EventBIValue) {}
    func notificationDiscussionPreferenceToggle(action: Bool) {}
    func notificationPreferencesToggleBatchState(discussionsActivity: Bool) {}
    func notificationSystemPermissionDialogAction(action: String) {}
    func notificationAppPermissionRationaleDialogAction(action: String) {}
    func notificationInboxMenuClicked() {}
    func notificationMarkAllReadClicked() {}
    func notificationPushNotificationsSettingClicked() {}
    func notificationInboxItemClicked(
        notificationDomain: String,
        notificationType: String,
        notificationID: String,
        courseID: String?,
        topicID: String?,
        threadID: String?,
        responseID: String?,
        commentID: String?
    ) {}
}
#endif
