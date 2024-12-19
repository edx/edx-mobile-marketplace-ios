//
//  NotificationsSettingsViewModel.swift
//  Notifications
//
//  Created by Saeed Bashir on 12/13/24.
//

import Foundation
import Core
import SwiftUI

public class NotificationsSettingsViewModel: ObservableObject {
    @Published var showError: Bool = false
    public var hasPermission: Bool = false
    private var interactor: NotificationsInteractorProtocol
    private var analytics: NotificationsAnalytics
    var router: NotificationsRouter
    
    var errorMessage: String? {
        didSet {
            showError = errorMessage != nil
        }
    }
    
    public init(
        interactor: NotificationsInteractorProtocol,
        analytics: NotificationsAnalytics,
        router: NotificationsRouter
    ) {
        self.interactor = interactor
        self.analytics = analytics
        self.router = router
    }
    
    public func toggleNotificationsPermissionAction() {
        hasPermission.toggle()
        analytics.notificationsDiscussionPermissionToggleEvent(action: hasPermission)
    }
}
