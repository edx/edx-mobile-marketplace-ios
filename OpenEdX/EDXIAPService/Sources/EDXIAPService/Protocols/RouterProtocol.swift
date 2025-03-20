//
//  RouterProtocol.swift
//  EDXIAPService
//
//  Created by Vadim Kuznetsov on 4.03.25.
//
import OEXFoundation

@MainActor
protocol RouterProtocol {
    func navigateToUpgrade(style: EDXUpgradeInfoViewStyle, product: EDXProduct)
}
