//
//  XpertFive9ChatViewModel.swift
//  XpertFive9Chat
//
//  Created by Anton Yarmolenka on 19/09/2024.
//

import Foundation

public class XpertFive9ChatViewModel: ObservableObject {
    private var xpertConfiguration: XpertChatConfiguration
    
    init(xpertConfig: XpertChatConfiguration) {
        self.xpertConfiguration = xpertConfig
    }
        
    // swiftlint:disable line_length
    // MARK: Xpert
    public var xpertHTML: String {
        """
        <html>
            <head>
                <meta name="viewport" content="width=device-width, initial-scale=1, user-scalable=no, \
                viewport-fit=cover">
                <link rel="stylesheet" href="https://chatbot-frontend.prod.ai.2u.com/@latest/index.min.css" />
                <style type="text/css">
                    .intercom-lightweight-app-launcher {
                        display: none !important;
                    }
                </style>
                <style id="fit-graphics">
                    iframe {
                        width: 100% !important;
                        height: 100% !important;
                    }
                </style>
            </head>
            <body>
                <script>
                    window.XpertChatbotFrontend = {
                        xpertKey: '###XPERT_KEY###',
                        configurations: {
                            ###USE_CASE###
                            conversationScreen: {
                                liveChat: {
                                    options: {
                                        allowPopout: false
                                    },
                                },
                            },
                        },
                    };
                </script>
                <script type="module" src="https://chatbot-frontend.prod.ai.2u.com/@latest/index.min.js"></script>
                <script type="text/javascript" async="" src="https://cdn.segment.com/analytics.js/v1/###SEGMENTKEY###/analytics.min.js"></script>
                <script>
                    document.addEventListener(
                        "DOMSubtreeModified",
                        function(e) {
                            var container = document.getElementById("xpert-chatbot-container");
                            if (container != undefined) {
                                var button = container.getElementsByTagName("button")[0];
                                if (button != undefined && button.isClicked == undefined) {
                                    setTimeout(() => {
                                        button.click();
                                    }, 500);
                                    button.isClicked = true;
                                }
                            }
                            var xpertCloseButton = document.getElementsByClassName("xpert-chatbot-popup__header--btn-outline")[0];
                            if (xpertCloseButton != undefined) {
                                xpertCloseButton.addEventListener(
                                    "click",
                                    function(e) {
                                        window.webkit.messageHandlers.###closeChat###.postMessage("###closeChat###");
                                    },
                                    false
                                );
                            }
                        },
                        false
                    );
                </script>
            </body>
        </html>
        """
            .replacingOccurrences(of: "###XPERT_KEY###", with: xpertConfiguration.xpertKey)
            .replacingOccurrences(of: "###USE_CASE###", with: xpertConfiguration.useCaseString)
            .replacingOccurrences(of: "###SEGMENTKEY###", with: xpertConfiguration.segmentKey)
            .replacingOccurrences(of: "###closeChat###", with: WKScriptEvent.closeChat.rawValue)
    }
    // swiftlint:enable line_length
    
}
