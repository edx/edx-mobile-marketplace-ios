//
//  EDXIAPHelperProtocol.swift
//  EDXIAPService
//
//  Created by Vadim Kuznetsov on 30.05.25.
//

@MainActor
protocol EDXIAPHelperProtocol {
    func product(for object: Any) -> EDXProduct?
    func info(for product: EDXProduct) async throws -> EDXProductInfo
}
