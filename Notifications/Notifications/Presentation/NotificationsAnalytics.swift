//
//  NotificationsAnalytics.swift
//  Notifications
//
//  Created by Saeed Bashir on 11.12.2024.
//

import Foundation
import Core

public struct NotificationInfo {
    public let notificationDomain: String
    public let notificationType: String
    public let notificationID: String
    public let courseID: String?
    public let topicID: String?
    public let threadID: String?
    public let responseID: String?
    public let commentID: String?

    public init(
        notificationDomain: String,
        notificationType: String,
        notificationID: String,
        courseID: String?,
        topicID: String?,
        threadID: String?,
        responseID: String?,
        commentID: String?
    ) {
        self.notificationDomain = notificationDomain
        self.notificationType = notificationType
        self.notificationID = notificationID
        self.courseID = courseID
        self.topicID = topicID
        self.threadID = threadID
        self.responseID = responseID
        self.commentID = commentID
    }
}

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
    func notificationInboxItemClicked(_ notificationInfo: NotificationInfo)
    func notificationDiscussionPrimerViewed(dialogFrequency: Int)
    func notificationDiscussionPrimerAction(action: String)
    func notificationDiscussionPushReceived(_ notificationInfo: NotificationInfo)
    func notificationDiscussionPushTapped(_ notificationInfo: NotificationInfo)
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
    func notificationInboxItemClicked(_ notificationInfo: NotificationInfo) {}
    func notificationDiscussionPrimerViewed(dialogFrequency: Int) {}
    func notificationDiscussionPrimerAction(action: String) {}
    func notificationDiscussionPushReceived(_ notificationInfo: NotificationInfo) {}
    func notificationDiscussionPushTapped(_ notificationInfo: NotificationInfo) {}
}
#endif
