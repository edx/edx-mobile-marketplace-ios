// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI

public protocol EDXIAPServiceProtocol {
    func someTestView() -> any View
}

public class EDXIAPService: EDXIAPServiceProtocol {
    public func someTestView() -> any View {
        Text("Hello, IAP Plugin!")
    }
}
