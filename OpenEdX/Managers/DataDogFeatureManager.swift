//
//  DataDogFeatureManager.swift
//  OpenEdX
//
//  Created by Sumanta Roy on 01/04/26.
//

import Foundation
import EDXFeatureManagement
import Core
import WebKit

// MARK: - Adapter

final class DataDogFeatureManager: FeatureManagerProtocol, WebViewTrackingProtocol, TrackingConsentManaging {
    private var dataDogManager: FeatureManagerProtocol?
    private(set) var config: ConfigProtocol!
    
    init(_ config: ConfigProtocol, storage: CoreStorage) {
        self.config = config
        if config.dataDog.enabled {
            let trackingGranted = storage.datadogTrackingEnabled ?? true
            dataDogManager = DatadogManager(appID: config.dataDog.appID,
                                            clientToken: config.dataDog.clientToken,
                                            environment: config.dataDog.environment,
                                            trackingGranted: trackingGranted)
        }
    }
    
    func trackAutoEvents(_ hosts: Set<String>) {
        if config?.dataDog.enabled ?? false {
            dataDogManager?.trackAutoEvents(hosts)
        }
    }
        
    func identify(id: String, username: String?, email: String?) {
        if config?.dataDog.enabled ?? false {
            dataDogManager?.identify(id: id, username: username, email: email)
        }
    }
    
    func trackEvent(_ name: String, properties: [String: Any]?) {
        if config?.dataDog.enabled ?? false {
            dataDogManager?.trackEvent(name, properties: properties)
        }
    }
    
    func enableWebViewTracking(_ webView: WKWebView, _ hosts: Set<URL>) {
        dataDogManager?.enableWebViewTracking(webView, hosts)
    }
    
    func disableWebViewTracking(_ webView: WKWebView) {
        dataDogManager?.disableWebViewTracking(webView)
    }
    
    func trackURLSession(_ delegateClass: NSObject.Type) {
        dataDogManager?.trackURLSession(delegateClass)
    }

    func setTrackingConsent(granted: Bool) {
        if config?.dataDog.enabled ?? false {
            dataDogManager?.setTrackingConsent(granted: granted)
        }
    }
}
