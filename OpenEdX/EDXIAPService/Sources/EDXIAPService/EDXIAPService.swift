// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI
import OEXFoundation

public class EDXIAPService: IAPServiceProtocol {
    public func someTestView() -> UIView? {
        UIHostingController(rootView: Text("Hello, IAP Plugin!")).view
    }
    
    public init() {}
}
