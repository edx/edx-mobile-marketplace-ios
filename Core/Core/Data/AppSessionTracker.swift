//
//  AppSessionTracker.swift
//  Core
//
//  Created by Sumanta Roy on 27/07/26.

import Foundation
import UIKit

public protocol AppSessionTracking: AnyObject {
    var currentSessionID: Int { get }
    func registerAppLaunch()
}

public final class AppSessionTracker: AppSessionTracking {

    private var storage: SubscriptionBannerStorage
    private var didRegisterLaunch = false

    public var currentSessionID: Int {
        storage.subscriptionBannerCurrentSessionID
    }

    public init(storage: SubscriptionBannerStorage) {
        self.storage = storage
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }

    public func registerAppLaunch() {
        guard !didRegisterLaunch else { return }
        didRegisterLaunch = true
        incrementSession()
    }

    @objc
    private func appWillEnterForeground() {
        incrementSession()
    }

    private func incrementSession() {
        storage.subscriptionBannerCurrentSessionID += 1
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

#if DEBUG
public final class AppSessionTrackerMock: AppSessionTracking {
    public var currentSessionID: Int = 1
    public init() {}
    public func registerAppLaunch() {}
}
#endif
