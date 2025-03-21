//
//  NotificationsPrimerViewModel.swift
//  Notifications
//
//  Created by Muhammad Tayyab Akram on 2/14/25.
//

import Foundation
import SwiftUI
import UserNotifications
import Core

public final class NotificationsPrimerViewModel: ObservableObject {
    @Published private(set) var isUpdating = false

    private var openedSettings = false

    private let interactor: NotificationsInteractorProtocol
    private let router: NotificationsRouter
    private let analytics: NotificationsAnalytics

    private enum Constants {
        static let allow = "allow"
        static let discussionPrimer = "discussion_primer"
        static let dontAllow = "dont_allow"
        static let cancel = "cancel"
        static let `continue` = "continue"
        static let notifyMe = "notify_me"
        static let noThanks = "no_thanks"
    }

    public init(
        interactor: NotificationsInteractorProtocol,
        router: NotificationsRouter,
        analytics: NotificationsAnalytics
    ) {
        self.interactor = interactor
        self.router = router
        self.analytics = analytics

        addObservers()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func markAsShown() {
        trackScreenEvent()
        interactor.markPrimerAsShown()
    }

    func notifyMe() {
        trackDiscussionPrimerAction(action: Constants.notifyMe)

        Task {
            await requestNotificationPermissions()
        }
    }

    func noThanks() {
        trackDiscussionPrimerAction(action: Constants.noThanks)
        dismiss()
    }

    private func dismiss() {
        router.dismiss()
    }

    private func addObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(refreshSettings),
            name: .notificationRegistration,
            object: nil
        )
    }
    
    @objc private func didBecomeActive() {
        if openedSettings {
            Task {
                await enableNotificationsIfAuthorized()
            }
        }
    }

    @objc private func refreshSettings() {
        Task {
            await enableNotificationsIfAuthorized(track: true)
        }
    }

    @MainActor
    private func requestNotificationPermissions() async {
        isUpdating = true

        let settings = await UNUserNotificationCenter.current().notificationSettings()
        if settings.authorizationStatus == .notDetermined {
            router.performNotificationRegistration()
            trackSystemPermissionDialogViewed()
        } else {
            showPermissionNeededAlert()
        }
    }
    
    private func showPermissionNeededAlert() {
        let actions = [
            UIAlertAction(
                title: NotificationsLocalization.Alert.continue,
                style: .default,
                handler: { [weak self] _ in
                    self?.trackAppPermissionRationaleDialogAction(action: Constants.continue)
                    self?.openSettingsOrDismiss()
                }
            ),
            UIAlertAction(
                title: NotificationsLocalization.Alert.cancel,
                style: .default,
                handler: { [weak self] _ in
                    self?.trackAppPermissionRationaleDialogAction(action: Constants.cancel)
                    self?.dismiss()
                }
            )
        ]

        router.presentNativeAlert(
            title: NotificationsLocalization.Alert.permissionTitle,
            message: NotificationsLocalization.Alert.permissionMessage,
            actions: actions
        )
        trackAppPermissionRationaleDialogViewed()
    }

    private func openSettingsOrDismiss() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString),
              UIApplication.shared.canOpenURL(settingsURL) else {
            dismiss()
            return
        }

        UIApplication.shared.open(settingsURL)
        openedSettings = true
    }

    @MainActor
    private func enableNotificationsIfAuthorized(track: Bool = false) async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        if settings.authorizationStatus == .authorized {
            if track {
                trackSystemPermissionDialogAction(action: Constants.allow)
            }
            _ = try? await interactor.updateNotificationsPreferences(value: true)
        } else if settings.authorizationStatus == .denied {
            if track {
                trackSystemPermissionDialogAction(action: Constants.dontAllow)
            }
        }

        dismiss()
    }

    // MARK: - Analytics
    
    private func trackScreenEvent() {
        analytics.notificationDiscussionPrimerViewed(
            dialogFrequency: interactor.primerFrequency()
        )
    }

    private func trackDiscussionPrimerAction(action: String) {
        analytics.notificationDiscussionPrimerAction(action: action)
    }

    private func trackSystemPermissionDialogViewed() {
        analytics.notificationSystemPermissionDialogViewed(source: Constants.discussionPrimer)
    }

    private func trackSystemPermissionDialogAction(action: String) {
        analytics.notificationSystemPermissionDialogAction(
            source: Constants.discussionPrimer,
            action: action
        )
    }

    private func trackAppPermissionRationaleDialogViewed() {
        analytics.notificationAppPermissionRationaleDialogViewed(source: Constants.discussionPrimer)
    }

    private func trackAppPermissionRationaleDialogAction(action: String) {
        analytics.notificationAppPermissionRationaleDialogAction(
            source: Constants.discussionPrimer,
            action: action
        )
    }
}
