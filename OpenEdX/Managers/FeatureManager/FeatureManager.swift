//
//  FeatureManager.swift
//  OpenEdX
//
//  Created by Muhammad Tayyab Akram on 4/11/25.
//

import Foundation
import EDXFeatureManagement
import Core
/*
final class FeatureManager: FeatureManagerProtocol {
    private var optimizelyManager: FeatureManagerProtocol?

    init(config: ConfigProtocol) {
        if config.optimizely.enabled {
            optimizelyManager = OptimizelyFeatureManager(
                sdkKey: config.optimizely.sdkKey
            )
        }
    }

    func identifyUser(id: String, attributes: [String: Any]?) {
        optimizelyManager?.identifyUser(id: id, attributes: attributes)
    }

    func resetUser() {
        optimizelyManager?.resetUser()
    }

    func decision(forKey key: String) -> FeatureDecision? {
        return optimizelyManager?.decision(forKey: key)
    }

    func trackEvent(_ name: String, properties: [String: Any]?) {
        optimizelyManager?.trackEvent(name, properties: properties)
    }
}
*/
