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
    public let paymentSnackBarView: EDXPaymentSnackbarViewStyle
    public let mainColors: MainColors
    
    public init(
        mainColors: MainColors = MainColors(),
        dashboardButton: EDXDashboardButtonStyle = EDXDashboardButtonStyle(),
        upgradeInfoView: EDXUpgradeInfoViewStyle = EDXUpgradeInfoViewStyle(),
        paymentSnackBarView: EDXPaymentSnackbarViewStyle = EDXPaymentSnackbarViewStyle()
    ) {
        self.mainColors = mainColors
        self.dashboardButton = dashboardButton
        self.upgradeInfoView = upgradeInfoView
        self.paymentSnackBarView = paymentSnackBarView
    }
}
