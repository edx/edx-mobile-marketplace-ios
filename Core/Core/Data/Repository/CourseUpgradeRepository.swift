//
//  CourseUpgradeRepository.swift
//  Core
//
//  Created by Saeed Bashir on 4/23/24.
//

import Foundation

public protocol CourseUpgradeRepositoryProtocol {
    func createOrder(
        courseRunKey: String,
        currencyCode: String,
        price: NSDecimalNumber,
        receipt: String
    ) async throws -> FulfillOrder
}

public class CourseUpgradeRepository: CourseUpgradeRepositoryProtocol {
    private let api: API
    private let config: ConfigProtocol
    
    public init(api: API, config: ConfigProtocol) {
        self.api = api
        self.config = config
    }
    
    public func createOrder(
        courseRunKey: String,
        currencyCode: String,
        price: NSDecimalNumber,
        receipt: String
    ) async throws -> FulfillOrder {
        let result = try await api.requestData(
            CourseUpgradeEndpoint.createOrder(
                courseRunKey: courseRunKey,
                currencyCode: currencyCode,
                price: price,
                receipt: receipt
            )
        ).mapResponse(DataLayer.FulfillOrder.self)
        
        return result.domain
    }
}
