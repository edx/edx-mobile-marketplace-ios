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
    func navigateToUpgrade(style: EDXUpgradeInfoViewStyle, product: EDXProduct, helper: EDXIAPHelperProtocol)
    func presentNativeAlert(title: String?, message: String?, actions: [UIAlertAction])
}
