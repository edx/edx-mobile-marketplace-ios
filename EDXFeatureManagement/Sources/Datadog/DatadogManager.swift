//
//  DatadogManager.swift
//  EDXFeatureManagement
//
//  Created by Sumanta Roy on 04/02/26.
//

import DatadogCore
import DatadogRUM
import Foundation

public final class DatadogManager: NSObject {
    private(set) var appID: String = ""
    private(set) var clientToken = ""
    private(set) var environment = ""
    
    public init(appID: String, clientToken: String, environment: String) {
        self.appID = appID
        self.clientToken = clientToken
        self.environment = environment
        Datadog.initialize(
            with: Datadog.Configuration(
                clientToken: clientToken,
                env: environment,
                site: .us1
            ),
            trackingConsent: .granted
        )
    }
}

extension DatadogManager: FeatureManagerProtocol {
    public func trackEvent(_ name: String, properties: [String: Any]?) {

    }

    public func trackAutoEvents() {
        RUM.enable(
            with: RUM.Configuration(
                applicationID: appID,
                uiKitViewsPredicate: DefaultUIKitRUMViewsPredicate(),
                uiKitActionsPredicate: DefaultUIKitRUMActionsPredicate()
            )
        )
    }
}
