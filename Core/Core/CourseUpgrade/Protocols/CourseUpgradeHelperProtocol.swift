//
//  CourseUpgradeHelperProtocol.swift
//  Core
//
//  Created by Vadim Kuznetsov on 28.05.24.
//

import Foundation

//sourcery: AutoMockable
public protocol CourseUpgradeHelperProtocol {
    func setData(
        courseID: String,
        pacing: String,
        blockID: String?,
        localizedPrice: NSDecimalNumber?,
        localizedCurrencyCode: String?,
        lmsPrice: Double?,
        screen: CourseUpgradeScreen
    )
    
    func handleCourseUpgrade(
        upgradeHadler: CourseUpgradeHandler,
        state: UpgradeCompletionState,
        delegate: CourseUpgradeHelperDelegate?
    )
    
    func showRestorePurchasesAlert()
}
