//
//  WebViewTrustedHostsProtocol.swift
//  Core
//
//  Created by Sumanta Roy on 13/04/26.
//

import Foundation

public protocol WebViewTrustedHostsProtocol {
    var config: ConfigProtocol { get }
}

public extension WebViewTrustedHostsProtocol {
    var trustedHosts: Set<String> {
        var hosts = Set<String>()
        if let host = config.baseURL.host {
            hosts.insert(host)
        }
        if let urlString = config.discovery.webview.baseURL, let host = URL(string: urlString)?.host {
            hosts.insert(host)
        }
        if let urlString = config.program.webview.baseURL, let host = URL(string: urlString)?.host {
            hosts.insert(host)
        }
        return hosts
    }
}
