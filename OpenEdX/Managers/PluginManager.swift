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
    public private(set) var iapService: AnyIAPService?
    
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
    
    @MainActor
    func setIAPService(_ iapService: any IAPServiceProtocol) {
        self.iapService = AnyIAPService(iapService)
    }
}

// PluginManger + IAP.swift
import Core
import EDXIAPService
extension PluginManager: IAPManagerProtocol {
    public func configuration(for primary: PrimaryCourse) -> IAPConfiguration {
        EDXIAPConfiguration(
            productName: primary.name,
            sku: primary.sku ?? "",
            courseID: primary.courseID,
            isSelfPaced: primary.isSelfPaced,
            lmsPrice: primary.lmsPrice ?? .zero
        )
    }

    public func dashboardPrimaryCardButton(configuration: IAPConfiguration) -> AnyView? {
        iapService?.dashboardPrimaryCardButton(configuration: configuration)
    }
}
