//
//  FeatureManager.swift
//  OpenEdX
//
//  Created by Sumanta Roy on 09/02/26.
//

import Foundation
import EDXFeatureManagement
import Core

final class DataDogFeatureManager: FeatureManagerProtocol {
    private var dataDogManager: FeatureManagerProtocol?

    init(config: ConfigProtocol) {
        if config.dataDog.enabled {
            dataDogManager = DatadogManager(appID: config.dataDog.appID, clientToken: config.dataDog.clientToken, environment: config.dataDog.environment)
        }
    }
    
    func trackAutoEvents() {
        dataDogManager?.trackAutoEvents()
    }
    
    func trackEvent(_ name: String, properties: [String : Any]?) {
        dataDogManager?.trackEvent(name, properties: properties)
    }
}

