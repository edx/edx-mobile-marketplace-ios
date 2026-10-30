//
//  XpertChatbotInjection.swift
//  Core
//
//  Created by Sumanta Roy on 18.09.2026.
//

import WebKit

public struct XpertChatbotInjection: WebViewScriptInjectionProtocol {
    public var id: String = "XpertChatbotInjection"
    public var injectionTime: WKUserScriptInjectionTime = .atDocumentEnd
    public var forMainFrameOnly: Bool = true

    private let onReady: (WKWebView) -> Void

    public init(onReady: @escaping (WKWebView) -> Void) {
        self.onReady = onReady
    }

    public static func == (lhs: XpertChatbotInjection, rhs: XpertChatbotInjection) -> Bool {
        lhs.id == rhs.id
    }

    public var script: String {
        """
        (function() {
            // The native toolbar button replaces the widget's floating button, so hide it.
            // A hidden element still responds to programmatic click().
            var style = document.createElement('style');
            style.textContent = '#xpert_chatbot__floating-action-btn { display: none !important; }';
            (document.head || document.documentElement).appendChild(style);

            // The widget injects its floating button asynchronously, so it's looked up
            // at tap time rather than cached here.
            window.__triggerXpertChatbotAction = function() {
                var btn = document.getElementById('xpert_chatbot__floating-action-btn');
                if (btn) { btn.click(); }
            };
            window.webkit.messageHandlers.xpertChatbotReady.postMessage('');
        })();
        """
    }

    public var messages: [WebviewMessage]? {
        [
            WebviewMessage(name: "xpertChatbotReady") { [onReady] _, webView in
                guard let webView else { return }
                onReady(webView)
            }
        ]
    }
}
