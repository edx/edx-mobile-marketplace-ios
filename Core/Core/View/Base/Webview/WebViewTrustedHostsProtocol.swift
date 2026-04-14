//
//  WebViewTrustedHostsProtocol.swift
//  Core
//
//  Created by Sumanta Roy on 13/04/26.
//

import Foundation

public enum HostNavigationAction {
    case allow
    case silentCancel
    case outsideLink
}

public protocol WebViewTrustedHostsProtocol {
    var config: ConfigProtocol { get }
}

public extension WebViewTrustedHostsProtocol {
    
    var trustedHosts: Set<String> {
        var hosts = Set<String>()
        if let host = config.baseURL.host {
            hosts.insert(host)
        }
        if let urlString = config.discovery.webview.baseURL,
           let host = URL(string: urlString)?.host {
            hosts.insert(host)
        }
        if let urlString = config.program.webview.baseURL,
           let host = URL(string: urlString)?.host {
            hosts.insert(host)
        }
        return hosts
    }
    
    func classifyNavigation(
        destinationHost: String?,
        originHost: String?
    ) -> HostNavigationAction {
        guard let destinationHost,
              let originHost else { return .allow }
        
        guard trustedHosts.contains(destinationHost) else {
            return .outsideLink
        }
        
        // Silently cancel trusted cross-domain main-frame navigations
        // These should never replace the current webview content
        if destinationHost != originHost {
            return .silentCancel
        }
        
        return .allow
    }
}
