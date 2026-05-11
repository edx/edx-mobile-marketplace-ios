//
//  WebViewTrackingProtocol.swift
//  Core
//
//  Created by Sumanta Roy on 12/03/26.

import WebKit

public protocol WebViewTrackingProtocol {
    func enableWebViewTracking(_ webView: WKWebView, _ hosts: Set<URL>)
    func disableWebViewTracking(_ webView: WKWebView)
}

public struct WebViewTrackingMock: WebViewTrackingProtocol {
    public init() {}
    public func enableWebViewTracking(_ webView: WKWebView, _ hosts: Set<URL>) {}
    public func disableWebViewTracking(_ webView: WKWebView) {}
}
