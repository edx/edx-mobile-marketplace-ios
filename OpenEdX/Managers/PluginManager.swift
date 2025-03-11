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
    public private(set) var iapService: (any IAPServiceProtocol)?
    
    @MainActor
    public init() { }
    
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
    
    func setIAPService(_ iapService: any IAPServiceProtocol) {
        self.iapService = iapService
    }
}

// PluginManger + IAP.swift
import Core
import EDXIAPService
extension PluginManager: IAPManagerProtocol {
    public func configuration(for primaryCourse: PrimaryCourse) -> IAPConfiguration {
        EDXIAPConfiguration(productName: "", message: "", sku: "", courseID: "", isSelfPaced: false, lmsPrice: .zero)
    }
    public func dashboardPrimaryCardButton(configuration: IAPConfiguration) {
        
    }
}
