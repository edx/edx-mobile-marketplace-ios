//
//  CourseUpgradeHelperProtocol.swift
//  Core
//
//  Created by Vadim Kuznetsov on 28.05.24.
//

import Foundation
public protocol CourseUpgradeHelperDelegate: AnyObject {
    func hideAlertAction()
}

protocol CourseUpgradeHelperProtocol: Sendable {
    func setData(
        courseID: String,
        pacing: String,
        blockID: String?,
        localizedPrice: NSDecimalNumber?,
        localizedCurrencyCode: String?,
        lmsPrice: Double?,
        screen: EDXScreen
    )
    
    func handleCourseUpgrade(
        upgradeHadler: CourseUpgradeHandler,
        state: UpgradeCompletionState,
        delegate: CourseUpgradeHelperDelegate?
    )
    
    func showRestorePurchasesAlert()
}
