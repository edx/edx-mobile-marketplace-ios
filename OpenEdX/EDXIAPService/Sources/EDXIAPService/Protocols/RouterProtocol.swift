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

    func backToRoot(animated: Bool)
    
    @MainActor
    func hideUpgradeLoaderView(animated: Bool) async
    
    @MainActor
    func hideUpgradeInfo(animated: Bool) async
    
    @MainActor
    func showUpgradeLoaderView(animated: Bool, style: EDXIAPStyle) async
}
