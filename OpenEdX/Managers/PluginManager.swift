//
//  PluginManager.swift
//  OpenEdX
//
//  Created by Ivan Stepanok on 15.10.2024.
//

import Foundation
import OEXFoundation
import EDXIAPService

public class PluginManager {
    
    private(set) var analyticsServices: [AnalyticsService] = []
    private(set) var pushNotificationsProviders: [PushNotificationsProvider] = []
    private(set) var pushNotificationsListeners: [PushNotificationsListener] = []
    private(set) var iAPService: EDXIAPService?
    
    public init() {}
    
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
    
    func setIAPService(_ iAPService: EDXIAPService) {
        self.iAPService = iAPService
    }
}
