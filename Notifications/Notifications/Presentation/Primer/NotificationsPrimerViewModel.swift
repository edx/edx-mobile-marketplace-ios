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

    public init(
        interactor: NotificationsInteractorProtocol,
        router: NotificationsRouter
    ) {
        self.interactor = interactor
        self.router = router

        addObservers()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @MainActor
    func markAsShown() {
        interactor.markPrimerAsShown()
    }

    func notify() {
        Task {
            await requestNotificationPermissions()
        }
    }

    @MainActor
    func dismiss() {
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
            refreshSettings()
        }
    }

    @objc private func refreshSettings() {
        Task {
            await enableNotificationsIfAuthorized()
        }
    }

    @MainActor
    private func requestNotificationPermissions() async {
        isUpdating = true

        let settings = await UNUserNotificationCenter.current().notificationSettings()
        if settings.authorizationStatus == .notDetermined {
            router.performNotificationRegistration()
        } else {
            showPermissionNeededAlert()
        }
    }
    
    @MainActor
    private func showPermissionNeededAlert() {
        let actions = [
            UIAlertAction(
                title: NotificationsLocalization.Alert.continue,
                style: .default,
                handler: { [weak self] _ in
                    self?.openSettingsOrDismiss()
                }
            ),
            UIAlertAction(
                title: NotificationsLocalization.Alert.cancel,
                style: .default,
                handler: { [weak self] _ in
                    self?.dismiss()
                }
            )
        ]

        router.presentNativeAlert(
            title: NotificationsLocalization.Alert.permissionTitle,
            message: NotificationsLocalization.Alert.permissionMessage,
            actions: actions
        )
    }

    @MainActor
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
    private func enableNotificationsIfAuthorized() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        if settings.authorizationStatus == .authorized {
            _ = try? await interactor.updateNotificationsPreferences(value: true)
        }

        dismiss()
    }
}
