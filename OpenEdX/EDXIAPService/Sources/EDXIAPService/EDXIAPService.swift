// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI
import OEXFoundation

public class EDXIAPService: V2IAPServiceProtocol {
    public init() {}
    
    public func someTestView() -> AnyView {
        AnyView(
            Text("Hello, IAP Plugin V2!")
        )
    }
}
