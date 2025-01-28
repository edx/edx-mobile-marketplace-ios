//
//  PluginManager.swift
//  OpenEdX
//
//  Created by Ivan Stepanok on 15.10.2024.
//

import Foundation
import OEXFoundation
import SwiftUI

public class PluginManager {
    
    private(set) var analyticsServices: [AnalyticsService] = []
    private(set) var pushNotificationsProviders: [PushNotificationsProvider] = []
    private(set) var pushNotificationsListeners: [PushNotificationsListener] = []
    private(set) var iapService: IAPServiceProtocol
    
    @MainActor
    public init() {
        self.iapService = IAPCommonService()
    }
    
    func addPlugin(analyticsService: AnalyticsService) {
        analyticsServices.append(analyticsService)
    }

    func addPlugin(
        pushNotificationsProvider: PushNotificationsProvider,
        pushNotificationsListener: PushNotificationsListener
    ) {
        pushNotificationsProviders.append(pushNotificationsProvider)
        pushNotificationsListeners.append(pushNotificationsListener)
    }
    
    func setIAPService(_ iapService: IAPServiceProtocol) {
        self.iapService = iapService
    }
}
