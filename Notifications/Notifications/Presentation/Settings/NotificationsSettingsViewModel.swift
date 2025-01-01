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
    @Published var hasPermission: Bool {
        didSet {
            storage.notificationsSettingStatus = hasPermission
        }
    }
    
    private var interactor: NotificationsInteractorProtocol
    private var analytics: NotificationsAnalytics
    var router: NotificationsRouter
    var storage: CoreStorage
    var preferences: NotificationsPreferences?
    var isUpdating: Bool = false
    private var authorizationStatus: AuthorizationStatus?
    private var requestPermissions: Bool = false
    
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
        hasPermission = storage.notificationsSettingStatus ?? false
        getOSSettingsPermissionStatus()
        addObservers()
    }
    
    @MainActor
    public func getNotificaionsPreferences() async {
        do {
            preferences = try await interactor.getNotificationsPreferences()
            hasPermission = preferences?.discussionsEnabled != false
            && preferences?.coreEnabled != false
            && authorizationStatus == .authorized
        } catch {
            debugLog(error)
        }
    }
    
    @MainActor
    public func toggleNotificationsPermissionAction() async {
        switch authorizationStatus {
        case .notDetermined:
            hasPermission.toggle()
            showPermissionNeededAlert()
            return
        case .denied:
            hasPermission.toggle()
            showPermissionNeededAlert()
            return
        default:
            break
        }
        
        if isUpdating {
            hasPermission.toggle()
            return
        }
        
        isUpdating = true
        do {
            let update = try await interactor.updateNotificationsPreferences(value: hasPermission)
            analytics.notificationsDiscussionPermissionToggleEvent(action: hasPermission)
            if update.updatedValue != hasPermission {
                hasPermission = update.updatedValue
            }
            isUpdating = false
        } catch {
            isUpdating = false
            hasPermission.toggle()
            errorMessage = NotificationsLocalization.Error.generic
        }
    }
    
    @objc private func refreshOSSettingsPermissionStatus() {
        getOSSettingsPermissionStatus(autoUpdate: requestPermissions)
    }
    
    private func getOSSettingsPermissionStatus(autoUpdate: Bool = false) {
        UNUserNotificationCenter.current().getNotificationSettings(completionHandler: { [weak self] (settings) in
            if settings.authorizationStatus == .notDetermined {
                self?.authorizationStatus = .notDetermined
            } else if settings.authorizationStatus == .denied {
                self?.authorizationStatus = .denied
            } else if settings.authorizationStatus == .authorized {
                self?.authorizationStatus = .authorized
                if autoUpdate {
                    DispatchQueue.main.async {
                        self?.hasPermission.toggle()                    }
                    Task {
                        await self?.toggleNotificationsPermissionAction()
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
                    if self?.authorizationStatus == .notDetermined {
                        Task {
                            self?.requestPermissions = true
                            await self?.router.performNotificationRegistration()
                        }
                    } else {
                        if let appSettings = URL(string: UIApplication.openSettingsURLString),
                           UIApplication.shared.canOpenURL(appSettings) {
                            self?.requestPermissions = true
                            UIApplication.shared.open(appSettings)
                        }
                    }
                }
            ),
            UIAlertAction(
                title: NotificationsLocalization.Alert.cancel,
                style: .default,
                handler: { _ in
                    
                }
            )
        ]
        
        router.presentNativeAlert(
            title: NotificationsLocalization.Alert.permissionTitle,
            message: NotificationsLocalization.Alert.permissionMessage,
            actions: actions
        )
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
    
    @objc func didBecomeActive() {
        // refresh the settings status
        getOSSettingsPermissionStatus(autoUpdate: requestPermissions)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
