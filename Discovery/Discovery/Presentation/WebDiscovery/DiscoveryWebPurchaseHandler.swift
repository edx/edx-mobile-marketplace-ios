//
//  DiscoveryWebPurchaseHandler.swift
//  Discovery
//
//  Created by Sumanta Roy on 01/04/26.
//

import Foundation

public enum ProgramPurchaseState {
    case processing
    case success
    case error(Error)
}

//sourcery: AutoMockable
public protocol DiscoveryWebPurchaseHandler {
    typealias PurchaseCompletion = (ProgramPurchaseState) -> Void
    func canHandlePurchase(for url: URL) -> Bool
    func handlePurchase(for url: URL, completion: @escaping PurchaseCompletion)
}
