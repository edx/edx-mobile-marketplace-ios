//
//  EDXProductInfo.swift
//  EDXIAPService
//
//  Created by Vadim Kuznetsov on 4.03.25.
//
import OEXFoundation

public struct EDXProductInfo: IAPProductInfo {
    public var productName: String
    public var sku: String
    public var courseID: String
    public var isSelfPaced: Bool
    public var lmsPrice: Double
    // NEEDS WORK. Need to add info for course access: isUpgradeable, coursewareAccess and etc.
    public init(
        productName: String,
        sku: String,
        courseID: String,
        isSelfPaced: Bool,
        lmsPrice: Double
    ) {
        self.productName = productName
        self.sku = sku
        self.courseID = courseID
        self.isSelfPaced = isSelfPaced
        self.lmsPrice = lmsPrice
    }
}
