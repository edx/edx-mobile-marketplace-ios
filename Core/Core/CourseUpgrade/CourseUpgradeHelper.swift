//
//  CourseUpgradeHelper.swift
//  Core
//
//  Created by Saeed Bashir on 4/24/24.
//

import Foundation
import StoreKit
import SwiftUI
import MessageUI
import Alamofire
import Combine
import KeychainSwift

private let InProgressIAPListKey = "InProgressIAPListKey"

public struct CourseUpgradeHelperModel {
    let courseID: String
    let blockID: String?
    let screen: CourseUpgradeScreen?
}

public enum UpgradeCompletionState {
    case initial
    case payment
    case fulfillment(showLoader: Bool)
    case unverified(UpgradeError)
    case success(_ courseID: String, _ componentID: String?, _ screen: CourseUpgradeScreen?)
    case error(UpgradeError)
}

public enum UpgradeAlertType: String {
    case priceFetch = "price_fetch"
    case payment
    case execute
    case restore
    case unfulfilled
    case unverified
    case unknown
}

// These error actions are used to send in analytics
public enum UpgradeErrorAction: String {
    case refreshToRetry = "refresh"
    case reloadPrice = "reload_price"
    case emailSupport = "get_help"
    case close
}

// These alert actions are used to send in analytics
public enum UpgradeAlertAction: String {
    case close
    case continueWithoutUpdate = "continue_without_update"
    case getHelp = "get_help"
    case refresh
}

public enum Pacing: String {
    case selfPace = "self"
    case instructor
}

public protocol CourseUpgradeHelperDelegate: AnyObject {
    func hideAlertAction()
}

public class CourseUpgradeHelper: CourseUpgradeHelperProtocol {
    
    weak private(set) var delegate: CourseUpgradeHelperDelegate?
    private(set) var completion: (() -> Void)?
    private(set) var helperModel: CourseUpgradeHelperModel?
    private(set) var config: ConfigProtocol
    private(set) var analytics: CoreAnalytics
    
    private var pacing: String?
    private var courseID: String?
    private var blockID: String?
    private var screen: CourseUpgradeScreen = .unknown
    private var localizedPrice: NSDecimalNumber?
    private var localizedCurrencyCode: String?
    private var lmsPrice: Double?
    weak private(set) var upgradeHadler: CourseUpgradeHandler?
    private let router: BaseRouter
    private var storage: CoreStorage
    private var cancellables = Set<AnyCancellable>()
    private let keychain = KeychainSwift()
    
    public init(
        config: ConfigProtocol,
        analytics: CoreAnalytics,
        router: BaseRouter,
        storage: CoreStorage
    ) {
        self.config = config
        self.analytics = analytics
        self.router = router
        self.storage = storage
    }
    
    public func setData(
        courseID: String,
        pacing: String,
        blockID: String? = nil,
        localizedPrice: NSDecimalNumber?,
        localizedCurrencyCode: String?,
        lmsPrice: Double?,
        screen: CourseUpgradeScreen
    ) {
        self.courseID = courseID
        self.pacing = pacing
        self.blockID = blockID
        self.localizedPrice = localizedPrice
        self.screen = screen
        self.localizedCurrencyCode = localizedCurrencyCode
        self.lmsPrice = lmsPrice
        
        addObservers()
    }
    
    private func addObservers() {
        NotificationCenter.default
            .publisher(for: .courseUpgradeUILoadingShouldEnd)
            .sink { [weak self] _ in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.removeLoader(success: true, shouldRemoveView: true)
                }
            }
            .store(in: &cancellables)
    }
    
    public func handleCourseUpgrade(
        upgradeHadler: CourseUpgradeHandler,
        state: UpgradeCompletionState,
        delegate: CourseUpgradeHelperDelegate? = nil
    ) {
        self.delegate = delegate
        self.upgradeHadler = upgradeHadler
        
        updateInProgressIAP()
        
        switch state {
        case .fulfillment(let show):
            if show {
                showLoader()
            }
        case .success(let courseID, let blockID, let screen):
            helperModel = CourseUpgradeHelperModel(courseID: courseID, blockID: blockID, screen: screen)
            guard upgradeHadler.upgradeMode.isUserInitiated else {
                showSilentRefreshAlert()
                return
            }
            if screen != .courseComponent {
                removeLoader(success: true, shouldRemoveView: true)
            }
            postSuccessNotification()
        case .unverified(let error):
            showUnverifiedCourseModeAlert(error)
        case .error(let error):
            if case .paymentError = error {
                if error.isCancelled {
                    analytics.trackCourseUpgradePaymentError(
                        .courseUpgradePaymentCancelError,
                        biValue: .courseUpgradePaymentCancelError,
                        courseID: courseID ?? "",
                        blockID: blockID,
                        pacing: pacing ?? "",
                        localizedPrice: localizedPrice,
                        localizedCurrencyCode: localizedCurrencyCode,
                        lmsPrice: lmsPrice,
                        screen: screen,
                        error: error.formattedError
                    )
                } else {
                    analytics.trackCourseUpgradePaymentError(
                        .courseUpgradePaymentError,
                        biValue: .courseUpgradePaymentError,
                        courseID: courseID ?? "",
                        blockID: blockID,
                        pacing: pacing ?? "",
                        localizedPrice: localizedPrice,
                        localizedCurrencyCode: localizedCurrencyCode,
                        lmsPrice: lmsPrice,
                        screen: screen,
                        error: error.formattedError
                    )
                }
            } else {
                analytics.trackCourseUpgradeError(
                    courseID: courseID ?? "",
                    blockID: blockID,
                    pacing: pacing ?? "",
                    localizedPrice: localizedPrice,
                    localizedCurrencyCode: localizedCurrencyCode,
                    lmsPrice: lmsPrice,
                    screen: screen,
                    error: error.formattedError,
                    flowType: upgradeHadler.upgradeMode
                )
            }
            
            var shouldRemove: Bool = false
            if case .verifyReceiptError = error {
                shouldRemove = false
            } else {
                shouldRemove = true
            }
            
            removeLoader(success: false, shouldRemoveView: shouldRemove)
        
        default:
            break
        }
    }
    
    private func updateInProgressIAP() {
        guard let state = upgradeHadler?.state,
              let courseID = courseID,
              let upgradeMode = upgradeHadler?.upgradeMode,
              let sku = upgradeHadler?.courseSku,
              sku.isEmpty == false
        else { return }
        
        switch state {
        case .initial:
            saveInProgressIAP(
                courseID: courseID,
                sku: sku,
                lmsPrice: lmsPrice ?? .zero,
                userID: storage.user?.id ?? .zero
            )
        case .complete:
            removeInProgressIAP(bySKU: sku)
        case .error(let upgradeError):
            switch upgradeError {
            case .verifyReceiptError(let error):
                if error.errorCode == 402 {
                    removeInProgressIAP(bySKU: sku)
                }
            case .unverifiedCourseError:
                break
            default:
                removeInProgressIAP(bySKU: sku)
            }
        default:
            break
        }
    }
    
    private func postSuccessNotification(showLoader: Bool = false) {
        NotificationCenter.default.post(name: .courseUpgradeCompletionNotification, object: showLoader)
    }
    
    private func showDashboardScreen() {
        router.backToRoot(animated: true)
    }
    
    public func resetUpgradeModel() {
        helperModel = nil
        delegate = nil
    }
    
    private func reset() {
        pacing = nil
        courseID = nil
        blockID = nil
        localizedPrice = nil
        screen = .unknown
        resetUpgradeModel()
    }
}

extension CourseUpgradeHelper {
    func trackAndResetOnSuccess() {
        analytics.trackCourseUpgradeSuccess(
            courseID: courseID ?? "",
            blockID: blockID,
            pacing: pacing ?? "",
            localizedPrice: localizedPrice,
            localizedCurrencyCode: localizedCurrencyCode,
            lmsPrice: lmsPrice,
            screen: screen,
            flowType: upgradeHadler?.upgradeMode ?? .userInitiated
        )
        reset()
    }
    
    func showError() {
        // not showing any error if payment is canceled by user
        if case .error(let error) = upgradeHadler?.state {
            if error.isCancelled { return }
            
            // Payment is already in progress; show alert for unverified course mode
            if case .verifyReceiptError(let nestedError) = error, nestedError.errorCode == 409 {
                showUnverifiedCourseModeAlert(error)
                return
            }
            
            // don't show alert for 402 error, in case of background restore
            if case .verifyReceiptError(let nestedError) = error,
               nestedError.errorCode == 402,
               upgradeHadler?.upgradeMode == .silent {
                return
            }
            
            var actions: [UIAlertAction] = []
            
            if case .verifyReceiptError(let nestedError) = error,
               nestedError.errorCode != 409 && nestedError.errorCode != 402 {
                actions.append(
                    UIAlertAction(
                        title: CoreLocalization.CourseUpgrade.FailureAlert.refreshToRetry,
                        style: .default,
                        handler: { [weak self] _ in
                            guard let self = self else { return }
                            self.trackUpgradeErrorAction(
                                errorAction: .refreshToRetry,
                                error: error,
                                alertType: .execute
                            )
                            Task {
                                await self.upgradeHadler?.reverifyPayment()
                            }
                        }
                    )
                )
            }
            
            if case .complete = upgradeHadler?.state, completion != nil {
                actions.append(
                    UIAlertAction(
                        title: CoreLocalization.CourseUpgrade.FailureAlert.refreshToRetry,
                        style: .default,
                        handler: { [weak self] _ in
                            self?.trackUpgradeErrorAction(
                                errorAction: .refreshToRetry,
                                error: error,
                                alertType: self?.alertType ?? .unknown
                            )
                            self?.showLoader()
                            self?.completion?()
                            self?.completion = nil
                        }
                    )
                )
            }
            
            actions.append(
                UIAlertAction(
                    title: CoreLocalization.CourseUpgrade.FailureAlert.getHelp,
                    style: .default,
                    handler: { [weak self] _ in
                        guard let self = self else { return }
                        self.trackUpgradeErrorAction(
                            errorAction: .emailSupport,
                            error: error,
                            alertType: self.alertType
                        )
                        self.hideAlertAction()
                        Task { @MainActor in
                            await self.router.hideUpgradeLoaderView(animated: true)
                        }
                        self.launchEmailComposer(errorMessage: "Error: \(error.formattedError)")
                    }
                )
            )

            actions.append(
                UIAlertAction(
                    title: CoreLocalization.close,
                    style: .default,
                    handler: { [weak self] _ in
                        guard let self = self else { return }
                        Task { @MainActor in
                            await self.router.hideUpgradeLoaderView(animated: true)
                            self.trackUpgradeErrorAction(errorAction: .close, error: error, alertType: self.alertType)
                            self.hideAlertAction()
                        }
                    }
                )
            )

            let message: String
            if case .generalError(let nestedError) = error {
                message = nestedError?.localizedDescription ?? error.localizedDescription
            } else {
                message = error.localizedDescription
            }
            
            doAfter(0.5) { [weak self] in
                self?.router.presentNativeAlert(
                    title: CoreLocalization.CourseUpgrade.FailureAlert.alertTitle,
                    message: message,
                    actions: actions
                )
            }
        }
    }
    
    private var alertType: UpgradeAlertType {
        switch upgradeHadler?.state {
        case .payment:
            return .payment
        case .verify, .complete:
            return .execute
        case .unverified:
            return .unverified
        default:
            return .unknown
        }
    }
    
    private func hideAlertAction() {
        delegate?.hideAlertAction()
        reset()
    }
}

extension CourseUpgradeHelper {
    private func showLoader(animated: Bool = false, completion: (() -> Void)? = nil) {
        Task {@MainActor [weak self] in
            guard let self = self else { return }
            await self.router.hideUpgradeInfo(animated: false)
            await self.router.showUpgradeLoaderView(animated: animated)
            completion?()
        }
    }
    
    private func removeLoader(
        success: Bool? = false,
        shouldRemoveView: Bool? = false,
        completion: (() -> Void)? = nil
    ) {
        self.completion = completion
        if success == true {
            helperModel = nil
        }
        
        if shouldRemoveView == true {
            Task {@MainActor in
                await router.hideUpgradeLoaderView(animated: true)
                helperModel = nil
                
                if success == true {
                    trackAndResetOnSuccess()
                } else {
                    showError()
                }
            }
        } else if success == false {
            showError()
        }
    }
}

extension CourseUpgradeHelper {
    private func showSilentRefreshAlert() {
        var actions: [UIAlertAction] = []

        actions.append(
            UIAlertAction(
                title: CoreLocalization.CourseUpgrade.SuccessAlert.silentAlertRefresh,
                style: .default
            ) { [weak self] _ in
                self?.showDashboardScreen()
                self?.postSuccessNotification(showLoader: true)
            }
        )
        
        actions.append(
            UIAlertAction(
                title: CoreLocalization.CourseUpgrade.SuccessAlert.silentAlertContinue,
                style: .default
            ) { [weak self] _ in
                self?.reset()
            }
        )

        router.presentNativeAlert(
            title: CoreLocalization.CourseUpgrade.SuccessAlert.silentAlertTitle,
            message: CoreLocalization.CourseUpgrade.SuccessAlert.silentAlertMessage,
            actions: actions
        )
    }
    
    public func showRestorePurchasesAlert() {
        var actions: [UIAlertAction] = []
        
        actions.append(
            UIAlertAction(
                title: CoreLocalization.CourseUpgrade.FailureAlert.getHelp,
                style: .default
            ) { [weak self] _ in
                self?.launchEmailComposer(errorMessage: "Error: restore_purchases")
                self?.trackUpgradeErrorAction(errorAction: .emailSupport, alertType: .restore)
            }
        )
        
        actions.append(
            UIAlertAction(
                title: CoreLocalization.close,
                style: .default
            ) { [weak self] _ in
                self?.trackUpgradeErrorAction(errorAction: .close, alertType: .restore)
            }
        )
        
        router.presentNativeAlert(
            title: CoreLocalization.CourseUpgrade.Restore.alertTitle,
            message: CoreLocalization.CourseUpgrade.Restore.alertMessage,
            actions: actions
        )
    }
    
    private func showUnverifiedCourseModeAlert(_ error: UpgradeError) {
        var actions: [UIAlertAction] = []
        
        actions.append(
            UIAlertAction(
                title: CoreLocalization.CourseUpgrade.FailureAlert.refreshToRetry,
                style: .default
            ) { [weak self] _ in
                guard let self = self else { return }
                self.trackUpgradeErrorAction(
                    errorAction: .refreshToRetry,
                    error: error,
                    alertType: self.alertType
                )
                
                Task {
                    await self.upgradeHadler?.reverifyCourseModeChange()
                }
            }
        )
        
        actions.append(
            UIAlertAction(
                title: CoreLocalization.CourseUpgrade.FailureAlert.getHelp,
                style: .default
            ) { [weak self] _ in
                guard let self = self else { return }
                self.trackUpgradeErrorAction(
                    errorAction: .emailSupport,
                    error: error,
                    alertType: .unverified
                )
                
                self.hideAlertAction()
                Task { @MainActor in
                    await self.router.hideUpgradeLoaderView(animated: true)
                }
                self.launchEmailComposer(errorMessage: "Error: \(error.formattedError)")
            }
        )
        
        actions.append(
            UIAlertAction(
                title: CoreLocalization.Alert.cancel,
                style: .default
            ) { [weak self] _ in
                guard let self = self else { return }
                self.trackUpgradeErrorAction(errorAction: .close, alertType: self.alertType)
                
                self.hideAlertAction()
                Task { @MainActor in
                    await self.router.hideUpgradeLoaderView(animated: true)
                }
            }
        )
        
        router.presentNativeAlert(
            title: CoreLocalization.CourseUpgrade.FailureAlert.alertTitle,
            message: CoreLocalization.CourseUpgrade.FailureAlert.courseNotFullfilled,
            actions: actions
        )
    }
}

extension CourseUpgradeHelper {
    private func trackUpgradeErrorAction(
        errorAction: UpgradeErrorAction,
        error: UpgradeError? = nil,
        alertType: UpgradeAlertType
    ) {
        analytics.trackCourseUpgradeErrorAction(
            courseID: courseID ?? "",
            blockID: blockID,
            pacing: pacing ?? "",
            localizedPrice: localizedPrice,
            localizedCurrencyCode: localizedCurrencyCode,
            lmsPrice: lmsPrice,
            screen: screen,
            alertType: alertType,
            errorAction: errorAction.rawValue,
            error: error?.formattedError ?? "",
            flowType: upgradeHadler?.upgradeMode ?? .userInitiated
        )
    }
}

extension CourseUpgradeHelper {
    func launchEmailComposer(errorMessage: String) {
        guard let emailURL = EmailTemplates.contactSupport(
            email: config.feedbackEmail,
            emailSubject: CoreLocalization.CourseUpgrade.supportEmailSubject,
            errorMessage: errorMessage
        ), UIApplication.shared.canOpenURL(emailURL) else {
            
            if let topController = UIApplication.topViewController() {
                UIAlertController().showAlert(
                    withTitle: CoreLocalization.CourseUpgrade.emailNotSetupTitle,
                    message: CoreLocalization.Error.cannotSendEmail,
                    cancelButtonTitle: CoreLocalization.ok,
                    onViewController: topController) { _, _, _ in }
            }
            
            return
        }
        
        UIApplication.shared.open(emailURL)
    }
}

// Save course upgrade data in user deualts for unfulfilled cases if any
// Enrollments API is paginated so it's not sure the course will be available in first response

extension CourseUpgradeHelper {
    public func isAllowedToPurchase(_ sku: String, courseID: String) -> Bool {
        guard let inProgressIAP = getInProgressIAP(bySKU: sku) else {
            return true // No existing purchase, so allowed
        }
        
        let isSameUser = storage.user?.id == inProgressIAP.userID
        let isSameSKU = inProgressIAP.sku == sku
        let isSameCourse = inProgressIAP.courseID == courseID
        
        return isSameUser && isSameSKU && isSameCourse
    }
    
    // Save or update
    private func saveInProgressIAP(courseID: String, sku: String, lmsPrice: Double, userID: Int) {
        let item = InProgressIAP(courseID: courseID, sku: sku, pacing: pacing ?? "", lmsPrice: lmsPrice, userID: userID)
        
        var list = CourseUpgradeHelper.getAllInProgressIAP(keychain, loggedInUserID: storage.user?.id ?? .zero)
        
        // Remove old item if sku already exists
        if let index = list.firstIndex(where: { $0.sku == item.sku }) {
            list[index] = item
        } else {
            list.append(item)
        }
        
        if let data = try? NSKeyedArchiver.archivedData(withRootObject: list, requiringSecureCoding: true) {
            keychain.set(data, forKey: InProgressIAPListKey)
        }
    }
    
    // Fetch single by SKU
    private func getInProgressIAP(bySKU sku: String) -> InProgressIAP? {
        return CourseUpgradeHelper.getAllInProgressIAP(
            keychain,
            loggedInUserID: storage.user?.id ?? .zero).first(where: { $0.sku == sku }
            )
    }
    
    // Delete single by SKU
    private func removeInProgressIAP(bySKU sku: String) {
        var list = CourseUpgradeHelper.getAllInProgressIAP(keychain, loggedInUserID: storage.user?.id ?? .zero)
        list.removeAll(where: { $0.sku == sku })
        
        if let data = try? NSKeyedArchiver.archivedData(withRootObject: list, requiringSecureCoding: true) {
            keychain.set(data, forKey: InProgressIAPListKey)
        }
    }
    
    // Get all
    public class func getAllInProgressIAP(
        _ keychain: KeychainSwift = KeychainSwift(),
        loggedInUserID: Int
    ) -> [InProgressIAP] {
        guard let data = keychain.getData(InProgressIAPListKey),
              let list = try? NSKeyedUnarchiver.unarchivedObject(
                ofClasses: [NSArray.self, InProgressIAP.self], from: data
              ) as? [InProgressIAP]
        else {
            return []
        }
        return list.filter { $0.userID == loggedInUserID }
    }
    
    // Delete all
    private func clearAllInProgressIAP() {
        keychain.delete(InProgressIAPListKey)
    }
}

public class InProgressIAP: NSObject, NSCoding, NSSecureCoding {
    
    public var courseID: String = ""
    public var sku: String = ""
    public var pacing: String = ""
    public var lmsPrice: Double = 0.0
    public var userID: Int
    
    init(courseID: String, sku: String, pacing: String, lmsPrice: Double, userID: Int) {
        self.courseID = courseID
        self.sku = sku
        self.pacing = pacing
        self.lmsPrice = lmsPrice
        self.userID = userID
    }
    
    public func encode(with coder: NSCoder) {
        coder.encode(courseID, forKey: "courseID")
        coder.encode(sku, forKey: "sku")
        coder.encode(pacing, forKey: "pacing")
        coder.encode(lmsPrice, forKey: "lmsPrice")
        coder.encode(userID, forKey: "userID")
    }
    
    public required init?(coder: NSCoder) {
        courseID = coder.decodeObject(forKey: "courseID") as? String ?? ""
        sku = coder.decodeObject(forKey: "sku") as? String ?? ""
        pacing = coder.decodeObject(forKey: "pacing") as? String ?? ""
        lmsPrice = coder.decodeDouble(forKey: "lmsPrice")
        userID = coder.decodeInteger(forKey: "userID")
    }
    
    public static var supportsSecureCoding: Bool {
        return true
    }
}
