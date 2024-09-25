//
//  XpertFive9HTMLWebViewRepresentable.swift
//  XpertFive9Chat
//
//  Created by Anton Yarmolenka on 19/09/2024.
//

import Foundation
import SwiftUI
import WebKit
import SafariServices

enum WKScriptEvent: String {
    case closeChat
    case openChat
}

struct XpertFive9HTMLWebViewRepresentable: UIViewRepresentable {
    var html: String?
    var baseURL: URL?
    @Binding var closeChat: Bool
    
    init(html: String?, baseURL: URL?, closeChat: Binding<Bool>) {
        self.html = html
        self.baseURL = baseURL
        self._closeChat = closeChat
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.defaultWebpagePreferences.preferredContentMode = .mobile
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        webView.backgroundColor = .clear

        #if DEBUG
        if #available(iOS 16.4, *) {
            webView.isInspectable = true
        } else {
            // Fallback on earlier versions
        }
        #endif

        webView.configuration.userContentController.add(
            context.coordinator,
            name: WKScriptEvent.closeChat.rawValue
        )
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
//        context.coordinator.wkWebview = webView
        if let html = html {
            webView.loadHTMLString(html, baseURL: baseURL)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        let coordinator: Coordinator = Coordinator(closeChat: $closeChat)
        return coordinator
    }
    
    static func dismantleUIView(_ uiView: WKWebView, coordinator: Coordinator) {
        uiView.configuration.userContentController.removeScriptMessageHandler(
            forName: WKScriptEvent.closeChat.rawValue
        )
    }
}

extension XpertFive9HTMLWebViewRepresentable {
    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {
        @Binding var closeChat: Bool
        
        init(closeChat: Binding<Bool>) {
            self._closeChat = closeChat
        }
//        weak var wkWebview: WKWebView?
        
        func userContentController(
            _ userContentController: WKUserContentController,
            didReceive message: WKScriptMessage
        ) {
            if message.name == WKScriptEvent.closeChat.rawValue {
                if !closeChat {
                    closeChat = true
                }
            }
        }

        func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
            if navigationAction.targetFrame == nil,
                let url = navigationAction.request.url {
                let controller = SFSafariViewController(url: url)
                controller.modalPresentationStyle = .pageSheet
                UIApplication.shared.rootViewController?.present(controller, animated: true)
            }
            print("WebView createWebViewWith")
            return nil
        }
    }
}
