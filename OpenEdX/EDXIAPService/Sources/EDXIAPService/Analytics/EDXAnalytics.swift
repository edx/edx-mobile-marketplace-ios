//
//  EDXAnalytics.swift
//  EDXIAPService
//
//  Created by Anton Yarmolenka on 05/05/2025.
//

import Foundation
import OEXFoundation

public struct EventParamKey {
    public static let pacing = "pacing"
    public static let courseID = "course_id"
    public static let screenName = "screen_name"
    public static let category = "category"
    public static let name = "name"
    public static let lmsPrice = "lms_usd_price"
    public static let localizedPrice = "localized_price"
    public static let localizedCurrencyCode = "localized_currency_code"
    public static let blockID = "block_id"
    public static let error = "error"
    public static let errorAction = "error_action"
    public static let flowType = "flow_type"
    public static let alertType = "alert_type"
}

public struct EventCategory {
    public static let inAppPurchases = "in_app_purchases"
}

public enum EventBIValue: String {
    case courseUpgradeValuePropViewed = "edx.bi.app.payments.value_prop.viewed"
    case upgradeNowClicked = "edx.bi.app.payments.upgrade_now.clicked"
    case courseUpgradePriceLoadError = "edx.bi.app.payments.price_load_error"
    case courseUpgradeErrorAction = "edx.bi.app.payments.error_alert_action"
    case courseUpgradePaymentCancelError = "edx.bi.app.payments.canceled_by_user"
    case courseUpgradePaymentError = "edx.bi.app.payments.payment_error"
    case courseUpgradeError = "edx.bi.app.payments.course_upgrade_error"
    case courseUpgradeSuccess = "edx.bi.app.payments.course_upgrade_success"
}

public enum AnalyticsEvent: String {
    case courseUpgradeValuePropViewed = "Payments:Value Prop Viewed"
    case upgradeNowClicked = "Payments:Upgrade Now Clicked"
    case courseUpgradePriceLoadError = "Payments:Price Load Error"
    case courseUpgradeErrorAction = "Payments:Error Alert Action"
    case courseUpgradePaymentCancelError = "Payments:Canceled by User"
    case courseUpgradePaymentError = "Payments:Payment Error"
    case courseUpgradeError = "Payments:Course Upgrade Error"
    case courseUpgradeSuccess = "Payments:Course Upgrade Success"
}

public struct EDXAnalytics: EDXAnalyticsProtocol {
    public let service: any AnalyticsService

    public init(service: AnalyticsService) {
        self.service = service
    }
    
    public func trackValuePropViewed(
        courseID: String,
        pacing: String,
        lmsPrice: Double,
        screen: EDXScreen
    ) {
        var parameters: [String: Any] = [
            EventParamKey.pacing: pacing,
            EventParamKey.courseID: courseID,
            EventParamKey.screenName: screen.rawValue,
            EventParamKey.category: EventCategory.inAppPurchases,
            EventParamKey.name: EventBIValue.courseUpgradeValuePropViewed.rawValue
        ]
        
        parameters.setObjectOrNil(lmsPrice, forKey: EventParamKey.lmsPrice)
        service.logScreenEvent(AnalyticsEvent.courseUpgradeValuePropViewed.rawValue, parameters: parameters)
    }
    
    public func trackUpgradeNow(
        courseID: String,
        blockID: String?,
        pacing: String,
        screen: EDXScreen,
        localizedPrice: NSDecimalNumber?,
        localizedCurrencyCode: String?,
        lmsPrice: Double?
    ) {
        var parameters: [String: Any] = [
            EventParamKey.pacing: pacing,
            EventParamKey.name: EventBIValue.upgradeNowClicked.rawValue,
            EventParamKey.courseID: courseID,
            EventParamKey.screenName: screen.rawValue,
            EventParamKey.category: EventCategory.inAppPurchases
        ]
        
        parameters.setObjectOrNil(localizedPrice, forKey: EventParamKey.localizedPrice)
        parameters.setObjectOrNil(localizedCurrencyCode, forKey: EventParamKey.localizedCurrencyCode)
        parameters.setObjectOrNil(lmsPrice, forKey: EventParamKey.lmsPrice)
        parameters.setObjectOrNil(blockID, forKey: EventParamKey.blockID)
        
        service.logEvent(AnalyticsEvent.upgradeNowClicked.rawValue, parameters: parameters)
    }
    
    public func trackCourseUpgradeLoadError(
        courseID: String,
        blockID: String? = nil,
        pacing: String,
        screen: EDXScreen
    ) {
        var parameters: [String: Any] = [
            EventParamKey.pacing: pacing,
            EventParamKey.name: EventBIValue.courseUpgradePriceLoadError.rawValue,
            EventParamKey.courseID: courseID,
            EventParamKey.screenName: screen.rawValue,
            EventParamKey.category: EventCategory.inAppPurchases
        ]
        
        parameters.setObjectOrNil(blockID, forKey: EventParamKey.blockID)
        
        service.logEvent(AnalyticsEvent.courseUpgradePriceLoadError.rawValue, parameters: parameters)
    }
    
    //swiftlint:disable:next function_parameter_count
    public func trackCourseUpgradeErrorAction(
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
    ) {
        var parameters: [String: Any] = [
            EventParamKey.pacing: pacing,
            EventParamKey.name: EventBIValue.courseUpgradeErrorAction.rawValue,
            EventParamKey.courseID: courseID,
            EventParamKey.screenName: screen.rawValue,
            EventParamKey.error: error,
            EventParamKey.errorAction: errorAction,
            EventParamKey.flowType: flowType.rawValue,
            EventParamKey.category: EventCategory.inAppPurchases,
            EventParamKey.alertType: alertType.rawValue
        ]
        
        parameters.setObjectOrNil(blockID, forKey: EventParamKey.blockID)
        parameters.setObjectOrNil(localizedPrice, forKey: EventParamKey.localizedPrice)
        parameters.setObjectOrNil(localizedCurrencyCode, forKey: EventParamKey.localizedCurrencyCode)
        parameters.setObjectOrNil(lmsPrice, forKey: EventParamKey.lmsPrice)
        
        service.logEvent(AnalyticsEvent.courseUpgradeErrorAction.rawValue, parameters: parameters)
    }
    
    public func trackCourseUpgradePaymentError(
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
    ) {
        var parameters: [String: Any] = [
            EventParamKey.pacing: pacing,
            EventParamKey.courseID: courseID,
            EventParamKey.screenName: screen.rawValue,
            EventParamKey.error: error,
            EventParamKey.category: EventCategory.inAppPurchases,
            EventParamKey.name: biValue.rawValue
        ]
        
        parameters.setObjectOrNil(localizedPrice, forKey: EventParamKey.localizedPrice)
        parameters.setObjectOrNil(localizedCurrencyCode, forKey: EventParamKey.localizedCurrencyCode)
        parameters.setObjectOrNil(lmsPrice, forKey: EventParamKey.lmsPrice)
        parameters.setObjectOrNil(blockID, forKey: EventParamKey.blockID)
        
        service.logEvent(event.rawValue, parameters: parameters)
    }
    
    public func trackCourseUpgradeError(
        courseID: String,
        blockID: String?,
        pacing: String,
        localizedPrice: NSDecimalNumber?,
        localizedCurrencyCode: String?,
        lmsPrice: Double?,
        screen: EDXScreen,
        error: String,
        flowType: EDXUpgradeMode
    ) {
        var parameters: [String: Any] = [
            EventParamKey.pacing: pacing,
            EventParamKey.name: EventBIValue.courseUpgradeError.rawValue,
            EventParamKey.courseID: courseID,
            EventParamKey.screenName: screen.rawValue,
            EventParamKey.error: error,
            EventParamKey.flowType: flowType.rawValue,
            EventParamKey.category: EventCategory.inAppPurchases
        ]
        
        parameters.setObjectOrNil(blockID, forKey: EventParamKey.blockID)
        parameters.setObjectOrNil(localizedPrice, forKey: EventParamKey.localizedPrice)
        parameters.setObjectOrNil(localizedCurrencyCode, forKey: EventParamKey.localizedCurrencyCode)
        parameters.setObjectOrNil(lmsPrice, forKey: EventParamKey.lmsPrice)
        
        service.logEvent(AnalyticsEvent.courseUpgradeError.rawValue, parameters: parameters)
    }
    
    public func trackCourseUpgradeSuccess(
        courseID: String,
        blockID: String?,
        pacing: String,
        localizedPrice: NSDecimalNumber?,
        localizedCurrencyCode: String?,
        lmsPrice: Double?,
        screen: EDXScreen,
        flowType: EDXUpgradeMode
    ) {
        var parameters: [String: Any] = [
            EventParamKey.pacing: pacing,
            EventParamKey.name: EventBIValue.courseUpgradeSuccess.rawValue,
            EventParamKey.courseID: courseID,
            EventParamKey.screenName: screen.rawValue,
            EventParamKey.flowType: flowType.rawValue,
            EventParamKey.category: EventCategory.inAppPurchases
        ]
        
        parameters.setObjectOrNil(localizedPrice, forKey: EventParamKey.localizedPrice)
        parameters.setObjectOrNil(localizedCurrencyCode, forKey: EventParamKey.localizedCurrencyCode)
        parameters.setObjectOrNil(lmsPrice, forKey: EventParamKey.lmsPrice)
        parameters.setObjectOrNil(blockID, forKey: EventParamKey.blockID)
        
        service.logEvent(AnalyticsEvent.courseUpgradeSuccess.rawValue, parameters: parameters)
    }
}
