//
//  EDXIAPStyle.swift
//  EDXIAPService
//
//  Created by Vadim Kuznetsov on 4.03.25.
//
import OEXFoundation

public struct EDXIAPStyle {
    public let dashboardButton: EDXDashboardButtonStyle
    public let upgradeInfoView: EDXUpgradeInfoViewStyle
    
    public init(
        dashboardButton: EDXDashboardButtonStyle = EDXDashboardButtonStyle(),
        upgradeInfoView: EDXUpgradeInfoViewStyle = EDXUpgradeInfoViewStyle()
    ) {
        self.dashboardButton = dashboardButton
        self.upgradeInfoView = upgradeInfoView
    }
}
