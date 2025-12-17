//
//  FirebaseAnalyticsTracker.swift
//  OpenEdX
//
//  Created by Sumanta Roy on 30/11/25.
//

import FirebaseAnalytics
import EDXFeatureManagement

public struct FirebaseAnalyticsTracker: AnalyticsTracking {
    public init() {}

    public func logEvent(_ name: String, parameters: [String: Any]?) {
        Analytics.logEvent(name, parameters: parameters)
    }
}
