//
//  DatadogManager.swift
//  EDXFeatureManagement
//
//  Created by Sumanta Roy on 04/02/26.
//

import DatadogCore
import DatadogWebViewTracking
import DatadogRUM
import Foundation
import WebKit

public final class DatadogManager: FeatureManagerProtocol {
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

extension DatadogManager {
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

    public func enableWebViewTracking(_ webView: WKWebView, _ hosts: Set<URL>) {
        hosts.forEach { url in
            if #available(iOS 16.0, *) {
                if let host = url.host(percentEncoded: true) {
                    WebViewTracking.enable(webView: webView, hosts: [host])
                }
            } else {
                if let host = url.host {
                    WebViewTracking.enable(webView: webView, hosts: [host])
                }
            }
        }
    }

    public func disableWebViewTracking(_ webView: WKWebView) {
        WebViewTracking.disable(webView: webView)
    }
}
