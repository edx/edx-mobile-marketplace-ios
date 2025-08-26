//
//  CourseUpgradeInteractorProtocol.swift
//  Core
//
//  Created by Vadim Kuznetsov on 22.05.24.
//

import Foundation

//sourcery: AutoMockable
public protocol CourseUpgradeInteractorProtocol {
    @discardableResult
    func createOrder(
        courseRunKey: String,
        currencyCode: String,
        price: NSDecimalNumber,
        receipt: String
    ) async throws -> FulfillOrder
}
