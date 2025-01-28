//
//  NotificationsRouter.swift
//  Notifications
//
//  Created by Saeed Bashir on 11.12.2024.
//

import Foundation
import Core

public protocol NotificationsRouter: BaseRouter {
    func showPushSettings()
}

// Mark - For testing and SwiftUI preview
#if DEBUG
public class NotificationsRouterMock: BaseRouterMock, NotificationsRouter {
    public override init() {}
    
    public func showPushSettings() {}
}
#endif
