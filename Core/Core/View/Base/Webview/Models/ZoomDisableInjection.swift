//
//  ZoomDisableInjection.swift
//  Core
//
//  Created by Raviteja Gurram on 18/02/26.
//
import WebKit

struct ZoomDisableInjection: WebViewScriptInjectionProtocol {
    let id = "ZoomDisableInjection"
    let script = """
    (function() {
        if (document.getElementById('ios-input-zoom-fix-style')) { return; }
        var style = document.createElement('style');
        style.id = 'ios-input-zoom-fix-style';
        style.textContent = 'input, textarea, select { font-size: 16px !important; }';
        document.head.appendChild(style);
    })();
    """
    let messages: [WebviewMessage]? = nil
    let injectionTime: WKUserScriptInjectionTime = .atDocumentEnd
    let forMainFrameOnly: Bool = true
}
