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
        Datadog.verbosityLevel = .debug
    }
}

extension DatadogManager {
    public func identify(id: String, username: String?, email: String?) {
        Datadog.setUserInfo(id: id, name: username, email: email)
    }
    public func trackEvent(_ name: String, properties: [String: Any]?) {
        var attributes: [String: any Encodable] = [:]
        properties?.forEach { key, value in
            guard let encodable = value as? any Encodable else {
                assertionFailure("Unsupported attribute type for key: \(key)")
                return
            }
            attributes[key] = encodable
        }
        RUMMonitor.shared().addAction(
            type: .custom,
            name: name,
            attributes: attributes
        )
    }
    public func trackAutoEvents(_ hosts: Set<String>) {
        RUM.enable(
            with: RUM.Configuration(
                applicationID: appID,
                uiKitViewsPredicate: DefaultUIKitRUMViewsPredicate(),
                uiKitActionsPredicate: DefaultUIKitRUMActionsPredicate(),
                urlSessionTracking: .init(
                    firstPartyHostsTracing: .trace(hosts: hosts,
                                                   sampleRate: 100))
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

    // swiftlint:disable force_cast
    public func trackURLSession(_ delegateClass: NSObject.Type) {
        let anyDelegateClass: AnyClass = delegateClass as AnyClass
        URLSessionInstrumentation.enable(
            with: .init(delegateClass: anyDelegateClass as! any URLSessionDataDelegate.Type)
        )
    }
    // swiftlint:enable force_cast
}
