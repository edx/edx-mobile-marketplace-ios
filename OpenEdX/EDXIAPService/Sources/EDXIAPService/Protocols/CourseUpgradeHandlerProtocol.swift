//
//  CourseUpgradeHandlerProtocol.swift
//  Core
//
//  Created by Vadim Kuznetsov on 22.05.24.
//

import Foundation

//sourcery: AutoMockable
protocol CourseUpgradeHandlerProtocol: Sendable {
    typealias UpgradeCompletionHandler = (UpgradeState) -> Void
    
    func upgradeCourse(
        sku: String?,
        mode: UpgradeMode,
        productInfo: StoreProductInfo?,
        pacing: String,
        courseID: String,
        lmsPrice: Double,
        componentID: String?,
        screen: EDXScreen,
        completion: UpgradeCompletionHandler?
    ) async
    
    func fetchProduct(sku: String) async throws -> StoreProductInfo
}

#if DEBUG
final class CourseUpgradeHandlerProtocolMock: CourseUpgradeHandlerProtocol {
    func upgradeCourse(
        sku: String?,
        mode: UpgradeMode,
        productInfo: StoreProductInfo?,
        pacing: String,
        courseID: String,
        lmsPrice: Double,
        componentID: String?,
        screen: EDXScreen,
        completion: UpgradeCompletionHandler?
    ) async {}
    
    func fetchProduct(sku: String) async throws -> StoreProductInfo {
        StoreProductInfo(price: .zero)
    }
}
#endif
