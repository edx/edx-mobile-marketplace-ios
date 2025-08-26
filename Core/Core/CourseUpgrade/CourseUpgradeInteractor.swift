//
//  CourseUpgradeInteractor.swift
//  Core
//
//  Created by Saeed Bashir on 4/23/24.
//

import Foundation

public class CourseUpgradeInteractor: CourseUpgradeInteractorProtocol {
    
    private let repository: CourseUpgradeRepositoryProtocol
    
    public init(repository: CourseUpgradeRepositoryProtocol) {
        self.repository = repository
    }
    
    @discardableResult
    public func createOrder(
        courseRunKey: String,
        currencyCode: String,
        price: NSDecimalNumber,
        receipt: String
    ) async throws -> FulfillOrder {
        return try await repository.createOrder(
            courseRunKey: courseRunKey,
            currencyCode: currencyCode,
            price: price,
            receipt: receipt
        )
    }
}

public struct FulfillOrder {
    let orderId: String
    let orderNumber: String
}
