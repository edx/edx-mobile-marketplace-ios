//
//  ProgramPurchaseHandler.swift
//  OpenEdX
//
//  Created by Sumanta Roy on 01/04/26.
//

import Foundation
import Core
import Discovery

class ProgramPurchaseHandler: DiscoveryWebPurchaseHandler {

    private let config: ConfigProtocol
    private let storeKitHandler: StoreKitHandlerProtocol

    init(config: ConfigProtocol, storeKitHandler: StoreKitHandlerProtocol) {
        self.config = config
        self.storeKitHandler = storeKitHandler
    }

    func canHandlePurchase(for url: URL) -> Bool {
        guard config.programPurchase.enabled,
              !config.programPurchase.sku.isEmpty,
              let host = url.host
        else {
            return false
        }
        let hostMatches = host == config.programPurchase.purchaseUrlHost
        let pathMatches = config.programPurchase.purchaseUrlPath.isEmpty
            || url.path == config.programPurchase.purchaseUrlPath
        let canPurchase = hostMatches && pathMatches
        return canPurchase
    }

    func handlePurchase(for url: URL, completion: @escaping PurchaseCompletion) {
        let sku = config.programPurchase.sku
        completion(.processing)
        Task {
            let response = await storeKitHandler.purchaseProduct(sku)
            await MainActor.run {
                if response.success {
                    storeKitHandler.markPurchaseComplete(sku, type: .purchase)
                    // TODO: send response.receipt to backend fulfillment API when ready
                    completion(.success)
                } else {
                    completion(.error(response.error ?? .generalError(nil)))
                }
            }
        }
    }
}
