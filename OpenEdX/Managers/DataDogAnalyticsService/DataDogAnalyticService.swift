//
//  DataDogAnalyticService.swift
//  OpenEdX
//
//  Created by Raviteja Gurram on 06/03/26.
//

import Foundation
import Core
import EDXFeatureManagement

class DataDogAnalyticsService: AnalyticsService {
    private let dataDogManager: DataDogFeatureManager?
    
    init(dataDogManager: DataDogFeatureManager?) {
        self.dataDogManager = dataDogManager
    }
    
    func identify(id: String, username: String?, email: String?) {
        dataDogManager?.identify(id: id, username: username, email: email)
    }
    func logEvent(_ event: Core.AnalyticsEvent, parameters: [String: Any]?) {
        dataDogManager?.trackEvent(event.rawValue, properties: parameters)
    }
    func logScreenEvent(_ event: Core.AnalyticsEvent, parameters: [String : Any]?) {
        dataDogManager?.trackEvent(event.rawValue, properties: parameters)
    }
}
