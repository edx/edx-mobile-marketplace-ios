//
//  SubscriptionAlertBannerViewModel.swift
//  Core
//
//  Created by Sumanta Roy on 27/07/26.

import Foundation

public final class SubscriptionAlertBannerViewModel: ObservableObject {

    @Published public private(set) var isVisible: Bool = false

    public var url: URL? {
        serverConfig.subscriptionBannerConfig.url ?? URL(string: "https://edx.org")
    }

    private let screen: SubscriptionBannerScreen
    private let storage: SubscriptionBannerStorage
    private let sessionTracker: AppSessionTracking
    private let serverConfig: ServerConfigProtocol

    public init(
        screen: SubscriptionBannerScreen,
        storage: SubscriptionBannerStorage,
        sessionTracker: AppSessionTracking,
        serverConfig: ServerConfigProtocol
    ) {
        self.screen = screen
        self.storage = storage
        self.sessionTracker = sessionTracker
        self.serverConfig = serverConfig
    }

    public func evaluateVisibility() {
        guard serverConfig.subscriptionBannerConfig.enabled else {
            isVisible = false
            return
        }

        guard !storage.isSubscriptionBannerDismissed(for: screen) else {
            isVisible = false
            return
        }

        let currentSessionID = sessionTracker.currentSessionID
        let alreadyCountedThisSession = storage.subscriptionBannerLastCountedSession(for: screen) == currentSessionID
        let maxSessions = serverConfig.subscriptionBannerConfig.maxSessions

        if alreadyCountedThisSession {
            isVisible = storage.subscriptionBannerShownSessionCount(for: screen) <= maxSessions
        } else {
            guard storage.subscriptionBannerShownSessionCount(for: screen) < maxSessions else {
                isVisible = false
                return
            }
            storage.recordSubscriptionBannerShown(for: screen, sessionID: currentSessionID)
            isVisible = true
        }
    }

    public func dismiss() {
        storage.setSubscriptionBannerDismissed(for: screen)
        isVisible = false
    }
}
