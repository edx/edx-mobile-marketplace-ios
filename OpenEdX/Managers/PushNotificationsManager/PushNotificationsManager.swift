//
//  PushNotificationManager.swift
//  OpenEdX
//
//  Created by Anton Yarmolenka on 24/01/2024.
//

import Foundation
import Core
import UIKit
import UserNotifications
import FirebaseCore
import FirebaseMessaging
import Notifications

public protocol PushNotificationsProvider {
    func didRegisterWithDeviceToken(deviceToken: Data)
    func didFailToRegisterForRemoteNotificationsWithError(error: Error)
    func synchronizeToken()
    func refreshToken()
}

protocol PushNotificationsListener {
    func shouldListenNotification(userinfo: [AnyHashable: Any]) -> Bool
    func didReceiveRemoteNotification(userInfo: [AnyHashable: Any])
}

class PushNotificationsManager: NSObject {
    
    private let deepLinkManager: DeepLinkManager
    private let storage: CoreStorage
    private let api: API
    private let analytics: NotificationsAnalytics

    private var providers: [PushNotificationsProvider] = []
    private var listeners: [PushNotificationsListener] = []
    
    public var hasProviders: Bool {
        providers.count > 0
    }
    
    // Init manager
    public init(
        deepLinkManager: DeepLinkManager,
        storage: CoreStorage,
        api: API,
        analytics: NotificationsAnalytics,
        config: ConfigProtocol
    ) {
        self.deepLinkManager = deepLinkManager
        self.storage = storage
        self.analytics = analytics
        self.api = api
        
        super.init()
        providers = providersFor(config: config)
        listeners = listenersFor(config: config)
    }
    
    private func providersFor(config: ConfigProtocol) -> [PushNotificationsProvider] {
        var pushProviders: [PushNotificationsProvider] = []
        if config.braze.pushNotificationsEnabled {
            pushProviders.append(BrazeProvider())
        }
        if config.firebase.cloudMessagingEnabled {
            pushProviders.append(FCMProvider(storage: storage, api: api))
        }
        return pushProviders
    }
    
    private func listenersFor(config: ConfigProtocol) -> [PushNotificationsListener] {
        var pushListeners: [PushNotificationsListener] = []
        if config.braze.pushNotificationsEnabled {
            pushListeners.append(BrazeListener(deepLinkManager: deepLinkManager))
        }
        if config.firebase.cloudMessagingEnabled {
            pushListeners.append(FCMListener(deepLinkManager: deepLinkManager))
        }
        return pushListeners
    }
    
    // Register for push notifications
    public func performRegistration() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
            NotificationCenter.default.post(
                name: .notificationRegistration,
                object: nil,
                userInfo: [Notification.UserInfoKey.status: granted]
            )
            if granted {
                debugLog("Permission for push notifications granted.")
            } else if let error = error {
                debugLog("Push notifications permission error: \(error.localizedDescription)")
            } else {
                debugLog("Permission for push notifications denied.")
            }
        }
    }
    
    // Proccess functions from app delegate
    public func didRegisterForRemoteNotificationsWithDeviceToken(deviceToken: Data) {
        for provider in providers {
            provider.didRegisterWithDeviceToken(deviceToken: deviceToken)
        }
    }
    public func didFailToRegisterForRemoteNotificationsWithError(error: Error) {
        for provider in providers {
            provider.didFailToRegisterForRemoteNotificationsWithError(error: error)
        }
    }
    public func didReceiveRemoteNotification(userInfo: [AnyHashable: Any]) {
        for listener in listeners {
            listener.didReceiveRemoteNotification(userInfo: userInfo)
        }
    }
    
    func synchronizeToken() {
        for provider in providers {
            provider.synchronizeToken()
        }
    }
    
    func refreshToken() {
        for provider in providers {
            provider.refreshToken()
        }
    }

    // MARK: - Analytics

    private func trackPushReceived(payload: [AnyHashable: Any]) {
        switch payload[PayloadKey.notificationDomain] as? String {
        case NotificationDomain.discussion:
            analytics.notificationDiscussionPushReceived(
                NotificationInfo(payload: payload)
            )
        default: break
        }
    }

    private func trackPushTapped(payload: [AnyHashable: Any]) {
        switch payload[PayloadKey.notificationDomain] as? String {
        case NotificationDomain.discussion:
            analytics.notificationDiscussionPushTapped(
                NotificationInfo(payload: payload)
            )
        default: break
        }
    }
}

// MARK: - MessagingDelegate
extension PushNotificationsManager: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        for provider in providers where provider is MessagingDelegate {
            (provider as? MessagingDelegate)?.messaging?(messaging, didReceiveRegistrationToken: fcmToken)
        }
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension PushNotificationsManager: UNUserNotificationCenterDelegate {
    @MainActor
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        if UIApplication.shared.applicationState == .active {
            let userInfo = notification.request.content.userInfo
            trackPushReceived(payload: userInfo) // For foreground state.
            didReceiveRemoteNotification(userInfo: userInfo)
            return []
        }
        
        return [[.list, .banner, .sound]]
    }
    
    @MainActor
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        let userInfo = response.notification.request.content.userInfo
        trackPushTapped(payload: userInfo) // For terminated and background state.
        didReceiveRemoteNotification(userInfo: userInfo)
    }
}

// MARK: - NotificationInfo

private enum PayloadKey {
    static let notificationDomain = "notification_domain"
    static let notificationType = "notification_type"
    static let notificationID = "notification_id"
    static let courseID = "course_id"
    static let topicID = "topic_id"
    static let threadID = "thread_id"
    static let parentID = "parent_id"
    static let commentID = "comment_id"
}

private enum NotificationDomain {
    static let discussion = "discussion"
}

private extension NotificationInfo {
    init(payload: [AnyHashable: Any]) {
        self.init(
            notificationDomain: (payload[PayloadKey.notificationDomain] as? String) ?? "",
            notificationType: (payload[PayloadKey.notificationType] as? String) ?? "",
            notificationID: (payload[PayloadKey.notificationID] as? String) ?? "",
            courseID: payload[PayloadKey.courseID] as? String,
            topicID: payload[PayloadKey.topicID] as? String,
            threadID: payload[PayloadKey.threadID] as? String,
            responseID: payload[PayloadKey.parentID] as? String,
            commentID: payload[PayloadKey.commentID] as? String
        )
    }
}
