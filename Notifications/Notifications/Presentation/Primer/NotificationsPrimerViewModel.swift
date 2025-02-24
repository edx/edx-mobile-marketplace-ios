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

    func markAsShown() {
        interactor.markPrimerAsShown()
    }

    func notify() {
        Task {
            await requestNotificationPermissions()
        }
    }

    func dismiss() {
        router.dismiss()
    }

    private func addObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(refreshSettings),
            name: .notificationRegistration,
            object: nil
        )
    }

    @objc private func refreshSettings() {
        Task {
            await enableNotificationsIfAuthorized()
        }
    }

    @MainActor
    private func requestNotificationPermissions() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        if settings.authorizationStatus == .notDetermined {
            isUpdating = true
            router.performNotificationRegistration()
        } else {
            router.dismiss(animated: true) {
                self.openSettingsIfPossible()
            }
        }
    }

    private func openSettingsIfPossible() {
        if let appSettings = URL(string: UIApplication.openSettingsURLString),
           UIApplication.shared.canOpenURL(appSettings) {
            UIApplication.shared.open(appSettings)
        }
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
