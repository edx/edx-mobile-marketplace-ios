//
//  NotificationsSettingsViewModel.swift
//  Notifications
//
//  Created by Saeed Bashir on 12/13/24.
//

import Foundation
import Core
import SwiftUI

private enum AuthorizationStatus {
    case notDetermined, denied, authorized
}

public class NotificationsSettingsViewModel: ObservableObject {
    @Published var showError: Bool = false
    @Published var discussionNotificationsEnabled: Bool {
        didSet {
            storage.discussionNotificationsSettingStatus = discussionNotificationsEnabled
        }
    }
    
    private var interactor: NotificationsInteractorProtocol
    private var analytics: NotificationsAnalytics
    private var storage: CoreStorage
    private var preferences: NotificationsPreferences?
    private var isUpdating: Bool = false
    private var authorizationStatus: AuthorizationStatus?
    private var openSettings: Bool = false
    var router: NotificationsRouter
    var errorMessage: String? {
        didSet {
            showError = errorMessage != nil
        }
    }
    
    public init(
        interactor: NotificationsInteractorProtocol,
        analytics: NotificationsAnalytics,
        router: NotificationsRouter,
        storage: CoreStorage
    ) {
        self.interactor = interactor
        self.analytics = analytics
        self.router = router
        self.storage = storage
        discussionNotificationsEnabled = storage.discussionNotificationsSettingStatus ?? false
        getOSSettingsPermissionStatus()
        addObservers()
    }
    
    @MainActor
    public func getNotificationsPreferences() async {
        do {
            preferences = try await interactor.getNotificationsPreferences()
            if let preferences {
                discussionNotificationsEnabled = preferences.discussionsEnabled
                    && preferences.coreEnabled
                    && authorizationStatus == .authorized
            }
        } catch {
            debugLog(error)
        }
    }
    
    @MainActor
    public func toggleDiscussionNotifications() async {
        trackDiscussionPermissionToggle(action: !discussionNotificationsEnabled)
        
        switch authorizationStatus {
        case .notDetermined:
            discussionNotificationsEnabled = false
            showSystemPermissionAlert()
            return
        case .denied:
            discussionNotificationsEnabled = false
            showPermissionNeededAlert()
            return
        default:
            break
        }
        
        await updateDiscussionNotifications(enabled: !discussionNotificationsEnabled)
    }
    
    @MainActor
    private func updateDiscussionNotifications(enabled: Bool) async {
        if isUpdating { return }
        isUpdating = true
        
        let previousValue = discussionNotificationsEnabled
        discussionNotificationsEnabled = enabled
        
        do {
            let update = try await interactor.updateNotificationsPreferences(value: discussionNotificationsEnabled)
            if update.updatedValue != discussionNotificationsEnabled {
                discussionNotificationsEnabled = update.updatedValue
            }
            isUpdating = false
        } catch {
            isUpdating = false
            discussionNotificationsEnabled = previousValue
            errorMessage = NotificationsLocalization.Error.generic
        }
    }
    
    @objc private func refreshOSSettingsPermissionStatus() {
        getOSSettingsPermissionStatus(autoUpdate: true, track: true)
    }
    
    private func getOSSettingsPermissionStatus(autoUpdate: Bool = false, track: Bool = false) {
        UNUserNotificationCenter.current().getNotificationSettings(completionHandler: { [weak self] (settings) in
            if settings.authorizationStatus == .notDetermined {
                self?.authorizationStatus = .notDetermined
            } else if settings.authorizationStatus == .denied {
                self?.authorizationStatus = .denied
                if track {
                    self?.trackSystemPermissionDialogAction(action: "dont_allow")
                }
            } else if settings.authorizationStatus == .authorized {
                self?.authorizationStatus = .authorized
                if track {
                    self?.trackSystemPermissionDialogAction(action: "allow")
                }
                if autoUpdate {
                    Task {
                        await self?.updateDiscussionNotifications(enabled: true)
                    }
                }
            }
        })
    }
    
    private func showPermissionNeededAlert() {
        let actions = [
            UIAlertAction(
                title: NotificationsLocalization.Alert.continue,
                style: .default,
                handler: { [weak self] _ in
                    self?.trackAppPermissionRationaleDialogAction(action: "continue")
                    
                    if self?.authorizationStatus == .notDetermined {
                        Task {
                            await self?.showSystemPermissionAlert()
                        }
                    } else {
                        if let appSettings = URL(string: UIApplication.openSettingsURLString),
                           UIApplication.shared.canOpenURL(appSettings) {
                            self?.openSettings = true
                            UIApplication.shared.open(appSettings)
                        }
                    }
                }
            ),
            UIAlertAction(
                title: NotificationsLocalization.Alert.cancel,
                style: .default,
                handler: { [weak self] _ in
                    self?.trackAppPermissionRationaleDialogAction(action: "cancel")
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

    @MainActor
    private func showSystemPermissionAlert() {
        router.performNotificationRegistration()
        trackSystemPermissionDialogViewed()
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
            selector: #selector(refreshOSSettingsPermissionStatus),
            name: .notificationRegistration,
            object: nil
        )
    }
    
    @objc private func didBecomeActive() {
        // refresh the settings status
        getOSSettingsPermissionStatus(autoUpdate: openSettings)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func trackScreenEvent() {
        analytics.notificationScreenEvent(.notificationSettings, biValue: .notificationSettings)
    }
    
    func trackDiscussionPermissionToggle(action: Bool) {
        analytics.notificationDiscussionPreferenceToggle(action: action)
    }
    
    func trackPreferencesToggleBatchState() {
        analytics.notificationPreferencesToggleBatchState(
            discussionsActivity: discussionNotificationsEnabled
        )
    }
    
    func trackSystemPermissionDialogViewed() {
        analytics.notificationScreenEvent(
            .notificationSystemPermissionDialogViewed,
            biValue: .notificationSystemPermissionDialogViewed
        )
    }
    
    func trackSystemPermissionDialogAction(action: String) {
        analytics.notificationSystemPermissionDialogAction(action: action)
    }
    
    func trackAppPermissionRationaleDialogViewed() {
        analytics.notificationScreenEvent(
            .notificationAppPermissionRationaleDialogViewed,
            biValue: .notificationAppPermissionRationaleDialogViewed
        )
    }
    
    func trackAppPermissionRationaleDialogAction(action: String) {
        analytics.notificationAppPermissionRationaleDialogAction(action: action)
    }
}
