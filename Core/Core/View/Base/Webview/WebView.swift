//
//  WebView.swift
//  Core
//
//  Created by  Stepanok Ivan on 07.10.2022.
//

import Combine
import Foundation
import SwiftUI
import Theme
import WebKit

public protocol WebViewNavigationDelegate: AnyObject {
    func webView(
        _ webView: WKWebView,
        shouldLoad request: URLRequest,
        navigationAction: WKNavigationAction
    ) async -> Bool
    
    func showWebViewError()
}

public struct WebView: UIViewRepresentable {
    
    public class ViewModel: ObservableObject {
        
        @Published var url: String
        let baseURL: String
        let injections: [WebviewInjection]?
        
        public init(url: String, baseURL: String, injections: [WebviewInjection]? = nil) {
            self.url = url
            self.baseURL = baseURL
            self.injections = injections
        }
    }
    
    @ObservedObject var viewModel: ViewModel
    @Binding public var isLoading: Bool
    var webViewNavDelegate: WebViewNavigationDelegate?
    
    var refreshCookies: () async -> Void
    var webViewType: String?
    private var scrollingHeader: AnyView?

    /// `scrollingHeader` adds native content above the webpage in the same scroll view.
    public init(
        viewModel: ViewModel,
        isLoading: Binding<Bool>,
        refreshCookies: @escaping () async -> Void,
        navigationDelegate: WebViewNavigationDelegate? = nil,
        webViewType: String? = nil,
        scrollingHeader: AnyView? = nil
    ) {
        self.viewModel = viewModel
        self._isLoading = isLoading
        self.refreshCookies = refreshCookies
        self.webViewNavDelegate = navigationDelegate
        self.webViewType = webViewType
        self.scrollingHeader = scrollingHeader
    }

    public class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {
        var cancellables: [AnyCancellable] = []
        var parent: WebView
        var url: URL?

        init(_ parent: WebView) {
            self.parent = parent
            super.init()

            addObservers()
        }

        public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            webView.isHidden = true
        }
        
        public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            webView.isHidden = false
            DispatchQueue.main.async {
                self.parent.isLoading = false
                self.parent.webViewNavDelegate?.showWebViewError()
            }
        }
        
        public func webView(
            _ webView: WKWebView,
            didFailProvisionalNavigation navigation: WKNavigation!,
            withError error: Error
        ) {
            webView.isHidden = false
            DispatchQueue.main.async {
                self.parent.isLoading = false
                self.parent.webViewNavDelegate?.showWebViewError()
            }
        }
        
        public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            webView.isHidden = false
            DispatchQueue.main.async {
                self.parent.isLoading = false
            }
        }

        public func webView(
            _ webView: WKWebView,
            runJavaScriptConfirmPanelWithMessage message: String,
            initiatedByFrame frame: WKFrameInfo,
            completionHandler: @escaping (Bool) -> Void
        ) {

            let alertController = UIAlertController(title: nil, message: message, preferredStyle: .actionSheet)

            alertController.addAction(UIAlertAction(
                title: CoreLocalization.ok,
                style: .default,
                handler: { _ in
                    completionHandler(true)
                }))

            alertController.addAction(UIAlertAction(
                title: CoreLocalization.Webview.Alert.cancel,
                style: .cancel,
                handler: { _ in
                    completionHandler(false)
                }))
            
            if let presenter = alertController.popoverPresentationController {
                let view = UIApplication.topViewController()?.view
                presenter.sourceView = view
                presenter.sourceRect = CGRect(
                    x: view?.bounds.midX ?? 0,
                    y: view?.bounds.midY ?? 0,
                    width: 0,
                    height: 0
                )
            }

            UIApplication.topViewController()?.present(alertController, animated: true, completion: nil)
        }

        public func webView(
            _ webView: WKWebView,
            decidePolicyFor navigationAction: WKNavigationAction
        ) async -> WKNavigationActionPolicy {
            
            guard let url = navigationAction.request.url else { return .cancel }
            
            let isWebViewDelegateHandled = await (
                parent.webViewNavDelegate?.webView(
                    webView,
                    shouldLoad: navigationAction.request,
                    navigationAction: navigationAction) ?? false
            )
            
            if isWebViewDelegateHandled {
                return .cancel
            }
            
            let baseURL = await parent.viewModel.baseURL
            switch navigationAction.navigationType {
            case .other, .formSubmitted, .formResubmitted:
                return .allow
            case .linkActivated:
                await MainActor.run {
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:])
                    }
                }
                return .cancel
            default:
                if !baseURL.isEmpty, !url.absoluteString.starts(with: baseURL) {
                    return .cancel
                } else {
                    return .allow
                }
            }
        }

        public func webView(
            _ webView: WKWebView,
            decidePolicyFor navigationResponse: WKNavigationResponse
        ) async -> WKNavigationResponsePolicy {
            guard let response = (navigationResponse.response as? HTTPURLResponse),
                  let url = response.url else {
                return .cancel
            }
            let baseURL = await parent.viewModel.baseURL

            if (401...404).contains(response.statusCode) || url.absoluteString.hasPrefix(baseURL + "/login") {
                await parent.refreshCookies()
                DispatchQueue.main.async {
                    if let url = webView.url {
                        let request = URLRequest(url: url)
                        webView.load(request)
                    }
                }
            }
            return .allow
        }
        
        private func addObservers() {
            cancellables.removeAll()
            NotificationCenter.default.publisher(for: Notification.Name(parent.webViewType ?? ""), object: nil)
                .sink { [weak self] _ in
                    self?.reload()
                }
                .store(in: &cancellables)

            NotificationCenter.default.publisher(for: UIContentSizeCategory.didChangeNotification, object: nil)
                .sink { [weak self] _ in
                    self?.webview?.evaluateSizeNotification()
                }
                .store(in: &cancellables)
        }

        fileprivate var webview: WKWebView?
        
        @objc private func reload() {
            DispatchQueue.main.async {
                self.parent.isLoading = true
            }
            if webview?.url?.absoluteString.isEmpty ?? true,
               let url = URL(string: parent.viewModel.url) {
                let request = URLRequest(url: url)
                webview?.load(request)
            } else {
                webview?.reload()
            }
        }

        public func userContentController(
            _ userContentController: WKUserContentController,
            didReceive message: WKScriptMessage
        ) {
            parent.viewModel.injections?.handle(message: message)
        }
    }

    private var userAgent: String {
        let info = Bundle.main.infoDictionary
        return [
            info?[kCFBundleExecutableKey as String],
            info?[kCFBundleIdentifierKey as String],
            info?["CFBundleShortVersionString"]
        ]
            .compactMap { $0 as? String ?? "" }
            .joined(separator: "/")
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    public func makeUIView(context: UIViewRepresentableContext<WebView>) -> WKWebView {
        let webViewConfig = WKWebViewConfiguration()
        
        let webView = ScrollingHeaderWebView(frame: .zero, configuration: webViewConfig)
        #if DEBUG
        if #available(iOS 16.4, *) {
            webView.isInspectable = true
        }
        #endif
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        
        context.coordinator.webview = webView
        
        webView.scrollView.bounces = false
        webView.scrollView.alwaysBounceHorizontal = false
        webView.scrollView.showsHorizontalScrollIndicator = false
        webView.scrollView.isScrollEnabled = true
        webView.configuration.suppressesIncrementalRendering = true
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = Theme.Colors.background.uiColor()
        webView.scrollView.alwaysBounceVertical = false
        webView.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        // To add ability to change font size with webkitTextSizeAdjust need to set mode to mobile
        webView.configuration.defaultWebpagePreferences.preferredContentMode = .mobile
        webView.applyInjections(viewModel.injections, toHandler: context.coordinator)
        
        webView.customUserAgent = userAgent
        context.coordinator.url = nil
        
        return webView
    }

    public func updateUIView(_ webview: WKWebView, context: UIViewRepresentableContext<WebView>) {
        if let headerWebView = webview as? ScrollingHeaderWebView {
            headerWebView.updateHeader(scrollingHeader, environment: context.environment)
        }
        if let url = URL(string: viewModel.url) {
            if context.coordinator.url?.absoluteString != url.absoluteString {
                DispatchQueue.main.async {
                    isLoading = true
                }
                context.coordinator.url = url
                let request = URLRequest(url: url)
                webview.load(request)
            }
        }
    }

    public static func dismantleUIView(_ uiView: WKWebView, coordinator: Coordinator) {
        (uiView as? ScrollingHeaderWebView)?.removeHeader()
        uiView.clear()
    }
}

private final class ScrollingHeaderWebView: WKWebView {
    private var headerController: UIHostingController<AnyView>?
    private var headerHeight: CGFloat = 0

    func updateHeader(_ content: AnyView?, environment: EnvironmentValues) {
        guard let content else {
            removeHeader()
            return
        }

        let rootView = AnyView(
            content
                .fixedSize(horizontal: false, vertical: true)
                .ignoresSafeArea()
                .environment(\.self, environment)
        )
        if let headerController {
            headerController.rootView = rootView
        } else {
            let controller = UIHostingController(rootView: rootView)
            controller.view.backgroundColor = .clear
            controller.view.clipsToBounds = true
            headerController = controller
        }
        attachHeader()
        setNeedsLayout()
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        if window == nil {
            detachHeader()
        } else {
            attachHeader()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        attachHeader()
        guard let headerController, headerController.parent != nil else { return }
        let insets = scrollView.adjustedContentInset
        let width = max(0, bounds.width - insets.left - insets.right)
        guard width > 0 else { return }

        // Measure independently of the current frame, which starts with zero height.
        let size = headerController.sizeThatFits(
            in: CGSize(width: width, height: .greatestFiniteMagnitude)
        )
        updateHeaderHeight(size.height)
        headerController.view.frame = CGRect(
            x: insets.left,
            y: -headerHeight,
            width: width,
            height: headerHeight
        )
    }

    private func attachHeader() {
        guard window != nil, let headerController, headerController.parent == nil else { return }
        var responder: UIResponder? = next
        while let current = responder {
            if let parent = current as? UIViewController {
                parent.addChild(headerController)
                scrollView.addSubview(headerController.view)
                headerController.didMove(toParent: parent)
                setNeedsLayout()
                return
            }
            responder = current.next
        }
    }

    private func detachHeader() {
        guard let headerController, headerController.parent != nil else { return }
        headerController.willMove(toParent: nil)
        headerController.view.removeFromSuperview()
        headerController.removeFromParent()
    }

    func removeHeader() {
        guard headerController != nil else { return }
        detachHeader()
        headerController = nil
        updateHeaderHeight(0)
    }

    private func updateHeaderHeight(_ height: CGFloat) {
        let height = ceil(height)
        guard height != headerHeight else { return }
        let previousOffset = scrollView.contentOffset
        let wasAtTop = previousOffset.y <= -scrollView.adjustedContentInset.top + 1

        // Reserve space above the HTML without changing WebKit's content size.
        var insets = scrollView.contentInset
        insets.top += height - headerHeight
        headerHeight = height
        scrollView.contentInset = insets

        let minimumOffset = -scrollView.adjustedContentInset.top
        let maximumOffset = max(
            minimumOffset,
            scrollView.contentSize.height - scrollView.bounds.height + scrollView.adjustedContentInset.bottom
        )
        let shouldResetToTop = wasAtTop || height == 0
        let offset = shouldResetToTop ? minimumOffset : min(maximumOffset, max(minimumOffset, previousOffset.y))
        scrollView.setContentOffset(CGPoint(x: previousOffset.x, y: offset), animated: false)
        setNeedsLayout()
    }
}

extension WKWebView {
    func evaluateSizeNotification() {
        let script = """
        function sendSizeEvent() {
            const contentSizeEvent = new CustomEvent("UIContentSizeCategory.didChangeNotification", { bubbles: true });
            window.dispatchEvent(contentSizeEvent);
        }
        sendSizeEvent();
        """
        evaluateJavaScript(script)
    }
    
    func applyInjections(_ injections: [WebviewInjection]?, toHandler handler: WKScriptMessageHandler) {
        for injection in injections ?? [] {
            let script = WKUserScript(
                source: injection.script,
                injectionTime: injection.injectionTime,
                forMainFrameOnly: injection.forMainFrameOnly
            )
            configuration.userContentController.addUserScript(script)
            
            for message in injection.messages ?? [] {
                configuration.userContentController.add(handler, name: message.name)
            }
        }
    }
    
    func clear() {
        configuration.userContentController.removeAllUserScripts()
        configuration.userContentController.removeAllScriptMessageHandlers()
    }
}

extension Array where Element == WebviewInjection {
    func handle(message: WKScriptMessage) {
        let messages = compactMap { $0.messages }
            .flatMap { $0 }
        if let currentMessage = messages.first(where: { $0.name == message.name }) {
            currentMessage.handler(message.body, message.webView)
        }
    }
}
