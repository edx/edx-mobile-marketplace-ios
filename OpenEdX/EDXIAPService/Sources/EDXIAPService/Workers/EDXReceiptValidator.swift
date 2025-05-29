//
//  EDXReceiptValidator.swift
//  EDXIAPService
//
//  Created by Vadim Kuznetsov on 30.05.25.
//

public struct EDXReceiptValidator: Sendable {
    private let networkService: EDXNetworkService = DefaultNetworkService()
    private let config: EDXServiceConfig
    
    public init(config: EDXServiceConfig) {
        self.config = config
    }

    func addBasket(sku: String) async throws -> EDXBasket {
        try await networkService.request(AddBasketRequest(sku: sku, ecommerceURL: config.ecommerceURL))
    }
    
    func checkoutBasket(basketID: Int) async throws {
        _ = try await networkService.request(
            CheckoutRequest(
                basketID: basketID,
                ecommerceURL: config.ecommerceURL,
                paymentProcessor: config.paymentProcessor
            )
        )
    }
    
    func fullfillCheckout(parameters: EDXFullfillParameters) async throws -> EDXReceiptStatus {
        try await networkService.request(
            FullfillCheckoutRequest(
                parameters: parameters,
                ecommerceURL: config.ecommerceURL,
                paymentProcessor: config.paymentProcessor
            )
        )
    }
}
