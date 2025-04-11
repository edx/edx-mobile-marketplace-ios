//
//  FeatureManager.swift
//  OpenEdX
//
//  Created by Muhammad Tayyab Akram on 4/11/25.
//

import Foundation
import EDXFeatureManagement
import Core

final class FeatureManager: FeatureManagementService {
    private var optimizelyService: FeatureManagementService?

    init(config: ConfigProtocol) {
        if config.optimizely.enabled {
            optimizelyService = OptimizelyFeatureManagementService(
                sdkKey: config.optimizely.sdkKey
            )
        }
    }

    func identifyUser(id: String, attributes: [String: Any]?) {
        optimizelyService?.identifyUser(id: id, attributes: attributes)
    }

    func resetUser() {
        optimizelyService?.resetUser()
    }

    func decision(forKey key: String) -> FeatureDecision? {
        return optimizelyService?.decision(forKey: key)
    }

    func trackEvent(_ name: String, properties: [String: Any]?) {
        optimizelyService?.trackEvent(name, properties: properties)
    }
}
