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
    private var router: NotificationsRouter
    private var analytics: NotificationsAnalytics
    
    var errorMessage: String? {
        didSet {
            withAnimation {
                showError = errorMessage != nil
            }
        }
    }
    
    public init(
        interactor: NotificationsInteractorProtocol,
        router: NotificationsRouter,
        analytics: NotificationsAnalytics
    ) {
        self.interactor = interactor
        self.router = router
        self.analytics = analytics
    }
    
    public func toggleNotificationsPermissionAction() {
        hasPermission.toggle()
        analytics.notificationsDiscussionPermissionToggleEvent(action: hasPermission)
    }
}
