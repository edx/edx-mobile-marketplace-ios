//
//  EDXServiceConfig.swift
//  EDXIAPService
//
//  Created by Vadim Kuznetsov on 30.05.25.
//

public struct EDXServiceConfig: Sendable {
    public var ecommerceURL: String
    public var paymentProcessor: String
    public var feedbackEmail: String
    
    public init(ecommerceURL: String, paymentProcessor: String, feedbackEmail: String) {
        self.ecommerceURL = ecommerceURL
        self.paymentProcessor = paymentProcessor
        self.feedbackEmail = feedbackEmail
    }
}
