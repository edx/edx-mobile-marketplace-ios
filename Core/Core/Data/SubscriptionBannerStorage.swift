//
//  SubscriptionBannerStorage.swift
//  Core
//
//  Created by Sumanta Roy on 27/07/26.

import Foundation

public enum SubscriptionBannerScreen: String {
    case discovery
    case profile
}

public protocol SubscriptionBannerStorage {
    var subscriptionBannerCurrentSessionID: Int { get set }

    func isSubscriptionBannerDismissed(for screen: SubscriptionBannerScreen) -> Bool
    func setSubscriptionBannerDismissed(for screen: SubscriptionBannerScreen)

    func subscriptionBannerLastCountedSession(for screen: SubscriptionBannerScreen) -> Int?
    func subscriptionBannerShownSessionCount(for screen: SubscriptionBannerScreen) -> Int
    func recordSubscriptionBannerShown(for screen: SubscriptionBannerScreen, sessionID: Int)
}

#if DEBUG
public class SubscriptionBannerStorageMock: SubscriptionBannerStorage {
    private var dismissed: [SubscriptionBannerScreen: Bool] = [:]
    private var lastCountedSession: [SubscriptionBannerScreen: Int] = [:]
    private var shownSessionCount: [SubscriptionBannerScreen: Int] = [:]

    public var subscriptionBannerCurrentSessionID: Int = 0

    public init() {}

    public func isSubscriptionBannerDismissed(for screen: SubscriptionBannerScreen) -> Bool {
        dismissed[screen] ?? false
    }

    public func setSubscriptionBannerDismissed(for screen: SubscriptionBannerScreen) {
        dismissed[screen] = true
    }

    public func subscriptionBannerLastCountedSession(for screen: SubscriptionBannerScreen) -> Int? {
        lastCountedSession[screen]
    }

    public func subscriptionBannerShownSessionCount(for screen: SubscriptionBannerScreen) -> Int {
        shownSessionCount[screen] ?? 0
    }

    public func recordSubscriptionBannerShown(for screen: SubscriptionBannerScreen, sessionID: Int) {
        lastCountedSession[screen] = sessionID
        shownSessionCount[screen] = (shownSessionCount[screen] ?? 0) + 1
    }
}
#endif
