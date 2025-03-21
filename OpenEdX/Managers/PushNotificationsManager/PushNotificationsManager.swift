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

    private func trackPushReceived(payload: Payload) {
        switch payload[.notificationDomain] {
        case EventCategory.discussion:
            analytics.notificationDiscussionPushReceived(
                NotificationInfo(payload: payload)
            )
        default: break
        }
    }

    private func trackPushTapped(payload: Payload) {
        switch payload[.notificationDomain] {
        case EventCategory.discussion:
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
            let payload = Payload(dictionary: userInfo)
            trackPushReceived(payload: payload) // For foreground state.
        }
        
        return [[.list, .banner, .sound]]
    }
    
    @MainActor
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        let userInfo = response.notification.request.content.userInfo
        let payload = Payload(dictionary: userInfo)
        trackPushTapped(payload: payload) // For terminated and background state.
        didReceiveRemoteNotification(userInfo: userInfo)
    }
}

// MARK: - NotificationInfo

private extension NotificationInfo {
    init(payload: Payload) {
        self.init(
            notificationDomain: payload[.notificationDomain] ?? "",
            notificationType: payload[.notificationType] ?? "",
            notificationID: payload[.notificationID] ?? "",
            courseID: payload[.courseID],
            topicID: payload[.topicID],
            threadID: payload[.threadID],
            responseID: payload[.responseID],
            commentID: payload[.commentID]
        )
    }
}
