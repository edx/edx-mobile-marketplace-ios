//
//  EDXAnalyticsProtocol.swift
//  EDXIAPService
//
//  Created by Anton Yarmolenka on 05/05/2025.
//

import Foundation
import OEXFoundation

public protocol EDXAnalyticsProtocol {
    var service: AnalyticsService { get }
    
    func trackValuePropViewed(
        courseID: String,
        pacing: String,
        lmsPrice: Double,
        screen: EDXScreen
    )
    
    func trackUpgradeNow(
        courseID: String,
        blockID: String?,
        pacing: String,
        screen: EDXScreen,
        localizedPrice: NSDecimalNumber?,
        localizedCurrencyCode: String?,
        lmsPrice: Double?
    )
    
    func trackCourseUpgradeLoadError(
        courseID: String,
        blockID: String?,
        pacing: String,
        screen: EDXScreen
    )

    //swiftlint:disable:next function_parameter_count
    func trackCourseUpgradeErrorAction(
        courseID: String,
        blockID: String?,
        pacing: String,
        localizedPrice: NSDecimalNumber?,
        localizedCurrencyCode: String?,
        lmsPrice: Double?,
        screen: EDXScreen,
        alertType: EDXUpgradeAlertType,
        errorAction: String,
        error: String,
        flowType: EDXUpgradeMode
    )
    
    func trackCourseUpgradePaymentError(
        _ event: AnalyticsEvent,
        biValue: EventBIValue,
        courseID: String,
        blockID: String?,
        pacing: String,
        localizedPrice: NSDecimalNumber?,
        localizedCurrencyCode: String?,
        lmsPrice: Double?,
        screen: EDXScreen,
        error: String
    )
    
    func trackCourseUpgradeError(
        courseID: String,
        blockID: String?,
        pacing: String,
        localizedPrice: NSDecimalNumber?,
        localizedCurrencyCode: String?,
        lmsPrice: Double?,
        screen: EDXScreen,
        error: String,
        flowType: EDXUpgradeMode
    )
    
    func trackCourseUpgradeSuccess(
        courseID: String,
        blockID: String?,
        pacing: String,
        localizedPrice: NSDecimalNumber?,
        localizedCurrencyCode: String?,
        lmsPrice: Double?,
        screen: EDXScreen,
        flowType: EDXUpgradeMode
    )
}
