//
//  RouterProtocol.swift
//  EDXIAPService
//
//  Created by Vadim Kuznetsov on 4.03.25.
//
import OEXFoundation
import UIKit

@MainActor
protocol RouterProtocol {
    func navigateToUpgrade(
        style: EDXIAPStyle,
        product: EDXProduct,
        helper: EDXIAPHelperProtocol,
        handler: CourseUpgradeHandlerProtocol,
        analyticsFacade: EDXAnalyticsProtocol
    )
    func presentNativeAlert(title: String?, message: String?, actions: [UIAlertAction])
}
