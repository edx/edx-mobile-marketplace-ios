//
//  FeatureManager.swift
//  OpenEdX
//
//  Created by Sumanta Roy on 09/02/26.
//

import Foundation
import EDXFeatureManagement
import Core
import WebKit

final class DataDogFeatureManager: FeatureManagerProtocol {
    private var dataDogManager: FeatureManagerProtocol?
    private(set) var config: ConfigProtocol!
    
    init(_ config: ConfigProtocol) {
        self.config = config
        if config.dataDog.enabled {
            dataDogManager = DatadogManager(appID: config.dataDog.appID, clientToken: config.dataDog.clientToken, environment: config.dataDog.environment)
        }
    }
    
    func trackAutoEvents() {
        if config?.dataDog.enabled ?? false {
            dataDogManager?.trackAutoEvents()
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
}
