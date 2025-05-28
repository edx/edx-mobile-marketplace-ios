//
//  CourseUpgradeHelperProtocol.swift
//  Core
//
//  Created by Vadim Kuznetsov on 28.05.24.
//

import Foundation

//sourcery: AutoMockable
// NEEDS WORK - delete, moved to plugin
public protocol CourseUpgradeHelperProtocol: Sendable {
    func setData(
        courseID: String,
        pacing: String,
        blockID: String?,
        localizedPrice: NSDecimalNumber?,
        localizedCurrencyCode: String?,
        lmsPrice: Double?,
        screen: CourseUpgradeScreen
    )
        
    func showRestorePurchasesAlert()
}

#if DEBUG
public final class CourseUpgradeHelperProtocolEmptyMock: CourseUpgradeHelperProtocol {
    public init() {}
    public func showRestorePurchasesAlert() {}
    
    public func setData(
        courseID: String,
        pacing: String,
        blockID: String?,
        localizedPrice: NSDecimalNumber?,
        localizedCurrencyCode: String?,
        lmsPrice: Double?,
        screen: CourseUpgradeScreen
    ) {}
}
#endif
