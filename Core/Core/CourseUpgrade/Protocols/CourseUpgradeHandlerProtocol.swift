//
//  CourseUpgradeHandlerProtocol.swift
//  Core
//
//  Created by Vadim Kuznetsov on 22.05.24.
//

import Foundation

//sourcery: AutoMockable
public protocol CourseUpgradeHandlerProtocol {
    typealias UpgradeCompletionHandler = (UpgradeState) -> Void
    
    func upgradeCourse(
        sku: String?,
        mode: UpgradeMode,
        productInfo: StoreProductInfo?,
        pacing: String,
        courseID: String,
        lmsPrice: Double,
        componentID: String?,
        screen: CourseUpgradeScreen,
        completion: UpgradeCompletionHandler?
    ) async
    
    func fetchProduct(sku: String) async throws -> StoreProductInfo
    
    func resolveUnfinishedPayments(
        loggedInUserID: Int,
        coreAnalytics: CoreAnalytics
    ) async
    
    func fulfillPurchase(
        inprogressIAP: InProgressIAP,
        product: StoreProductInfo,
        coreAnalytics: CoreAnalytics
    ) async
}

#if DEBUG
public class CourseUpgradeHandlerProtocolMock: CourseUpgradeHandlerProtocol {
    public init() {}
    
    public func upgradeCourse(
        sku: String?,
        mode: UpgradeMode,
        productInfo: StoreProductInfo?,
        pacing: String,
        courseID: String,
        lmsPrice: Double,
        componentID: String?,
        screen: CourseUpgradeScreen,
        completion: UpgradeCompletionHandler?
    ) async {}
    
    public func fetchProduct(sku: String) async throws -> StoreProductInfo {
        StoreProductInfo(price: .zero)
    }
    
    public func resolveUnfinishedPayments(
        loggedInUserID: Int,
        coreAnalytics: CoreAnalytics
    ) async {}
    
    public func fulfillPurchase(
        inprogressIAP: InProgressIAP,
        product: StoreProductInfo,
        coreAnalytics: CoreAnalytics
    ) async {}
}
#endif
