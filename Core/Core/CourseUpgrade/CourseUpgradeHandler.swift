//
//  CourseUpgradeHandler.swift
//  Core
//
//  Created by Saeed Bashir on 4/23/24.
//

import Foundation

public enum CourseUpgradeScreen: String {
    case dashboard
    case trackSelection = "track_selection"
    case courseDashboard = "course_dashboard"
    case courseComponent = "course_component"
    case unknown
}

public enum UpgradeMode: String {
    case silent
    case userInitiated = "user_initiated"
    case restore

    var isUserInitiated: Bool {
        return self == .userInitiated
    }
}

public enum UpgradeState {
    case initial
    case payment
    case verify
    case unverified(UpgradeError)
    case complete
    case error(UpgradeError)
}

private enum EnrollmentPollingError: Error {
    case courseNotVerified
}

public struct SKUBuilder {
    private static let minimum = 1.0
    private static let maximum = 1000.0

    public static func buildSKU(prefix: String, price: Double?) -> String {
        guard !prefix.isEmpty, let price = price else {
            return ""
        }
        return prefix + String(Int(price))
    }
    
    public static func isPriceValid(_ price: Double?) -> Bool {
        guard let price = price else { return false }
        return price >= minimum && price <= maximum
    }
}

private struct PollingConfig {
    let maxRetryCount: Int
    let baseDelayMilliseconds: Int
}

public class CourseUpgradeHandler: CourseUpgradeHandlerProtocol {
    static var ecommerceURL: String = ""
    
    private var completion: UpgradeCompletionHandler?
    private(set) var courseSku: String?
    private(set) var upgradeMode: UpgradeMode = .userInitiated
    private(set) var productInfo: StoreProductInfo?
    private var interactor: CourseUpgradeInteractorProtocol
    private var enrollmentInteractor: EnrollmentInteractorProtocol
    private var storeKitHandler: StoreKitHandlerProtocol
    private let helper: CourseUpgradeHelperProtocol
    private var courseID: String = ""
    private var lmsPrice: Double?
    private var componentID: String?
    private var screen: CourseUpgradeScreen?
    private var pollingConfig = PollingConfig(
        maxRetryCount: 3,
        baseDelayMilliseconds: 2500
    )

    private(set) var state: UpgradeState = .initial {
        didSet {
            helper.handleCourseUpgrade(
                upgradeHadler: self,
                state: upgradeState,
                delegate: nil
            )
            completion?(state)
        }
    }
    
    private var upgradeState: UpgradeCompletionState {
        switch state {
        case .initial:
            return .initial
        case .payment:
            return .payment
        case .verify:
            return .fulfillment(showLoader: upgradeMode.isUserInitiated)
        case .unverified(let error):
            return .unverified(error)
        case .complete:
            return .success(courseID, componentID, screen)
        case .error(let error):
            return .error(error)
        }
    }

    public init(
        config: ConfigProtocol,
        interactor: CourseUpgradeInteractorProtocol,
        enrollmentInteractor: EnrollmentInteractorProtocol,
        storeKitHandler: StoreKitHandlerProtocol,
        helper: CourseUpgradeHelperProtocol
    ) {
        self.interactor = interactor
        self.enrollmentInteractor = enrollmentInteractor
        self.storeKitHandler = storeKitHandler
        self.helper = helper
        CourseUpgradeHandler.ecommerceURL = config.ecommerceURL ?? ""
    }
    
    public func upgradeCourse(
        sku: String?,
        mode: UpgradeMode = .userInitiated,
        productInfo: StoreProductInfo?,
        pacing: String,
        courseID: String,
        lmsPrice: Double,
        componentID: String?,
        screen: CourseUpgradeScreen,
        completion: UpgradeCompletionHandler?
    ) async {
        self.completion = completion
        self.upgradeMode = mode
        self.courseID = courseID
        self.componentID = componentID
        self.productInfo = productInfo
        self.screen = screen
        courseSku = sku
        self.lmsPrice = lmsPrice
        guard let sku = sku, !sku.isEmpty else {
            state = .error(.generalError(error(message: "course sku is missing")))
            return
        }
        
        guard let productInfo = productInfo else {
            state = .error(.generalError(error(message: "product info is missing")))
            return
        }
        
        guard helper.isAllowedToPurchase(sku, courseID: courseID) else {
            state = .error(
                .generalError(
                    error(
                        message: CoreLocalization.CourseUpgrade.FailureAlert.generalErrorMessage
                    )
                )
            )
            return
        }
        
        helper.setData(
            courseID: courseID,
            pacing: pacing,
            blockID: componentID,
            localizedPrice: productInfo.price,
            localizedCurrencyCode: productInfo.currencyCode,
            lmsPrice: lmsPrice,
            screen: screen
        )
        state = .initial
        
        await checkCourseMode(sku)
    }
    
    @MainActor
    private func checkCourseMode(_ sku: String) async {
        do {
            let enrollmentDetails = try await self.enrollmentInteractor.getEnrollmentDetails(courseID: courseID)
            
            if enrollmentDetails.enrollmentMetadata?.mode == .verified {
                // Course is already purchased
                storeKitHandler.markPurchaseComplete(
                    courseSku ?? "",
                    type: (upgradeMode == .userInitiated) ? .purchase : .transction
                )
                state = .complete
            } else {
                if !upgradeMode.isUserInitiated {
                    await reverifyPayment()
                } else {
                    let response = await makePayment(sku: sku)
                    await verifyResponse(response)
                }
            }
        } catch let error {
            state = .error(.generalError(error))
        }
    }
    
    @MainActor
    private func makePayment(sku: String) async -> StoreKitUpgradeResponse {
        state = .payment
        return await storeKitHandler.purchaseProduct(sku)
    }
    
    private func verifyResponse(_ response: StoreKitUpgradeResponse) async {
        if let receipt = response.receipt, response.success {
            await verifyPayment(receipt)
        } else {
            await MainActor.run {
                state = .error(response.error ?? .paymentError(nil))
            }
        }
    }
    
    @MainActor
    private func verifyPayment(_ receipt: String) async {
        state = .verify
        debugLog("receipt: \(receipt)")
        do {
            try await interactor.createOrder(
                courseRunKey: courseID,
                currencyCode: productInfo?.currencyCode ?? "",
                price: productInfo?.price ?? 0.0,
                receipt: receipt
            )
            await verifyCourseModeChange()
        } catch let error {
            if error.errorCode == 402 {
                handleError402()
            } else {
                state = .error(.verifyReceiptError(error))
            }
        }
    }

    @MainActor
    private func handleError402() {
        storeKitHandler.markPurchaseComplete(
            courseSku ?? "",
            type: (upgradeMode == .userInitiated) ? .purchase : .transction
        )
        state = .error(.verifyReceiptError(emptyReceiptError()))
    }
    
    @MainActor
    private func verifyCourseModeChange() async {
        do {
            try await pollForVerifiedEnrollment(courseID: courseID, pollingConfig: pollingConfig) { courseID in
                let enrollmentDetails = try await self.enrollmentInteractor.getEnrollmentDetails(courseID: courseID)
                return enrollmentDetails.enrollmentMetadata?.mode
            }
            // Success flow
            storeKitHandler.markPurchaseComplete(
                courseSku ?? "",
                type: (upgradeMode == .userInitiated) ? .purchase : .transction
            )
            state = .complete
        } catch {
            debugLog("Enrollment failed to update to verified. Show retry dialog.")
            state = .unverified(.unverifiedCourseError(unverifiedCourseError()))
        }
    }
    
    private func pollForVerifiedEnrollment(
        courseID: String,
        pollingConfig: PollingConfig,
        fetchEnrollmentMode: @escaping (String) async throws -> DataLayer.Mode?
    ) async throws {
        for attempt in 1...pollingConfig.maxRetryCount {
            let delay = UInt64(attempt * pollingConfig.baseDelayMilliseconds) * 1_000_000
            try await Task.sleep(nanoseconds: delay)
            
            let mode = try await fetchEnrollmentMode(courseID)
            
            if mode == .verified {
                debugLog("Course mode updated to verified.")
                return
            } else {
                debugLog("Attempt \(attempt): Course mode is still '\(String(describing: mode))'. Retrying...")
            }
        }
        
        throw EnrollmentPollingError.courseNotVerified
    }
    
    // Give an option of retry to learner
    func reverifyPayment() async {
        let response = await storeKitHandler.purchaseReceipt()
        await verifyResponse(response)
    }
    
    func reverifyCourseModeChange() async {
        await verifyCourseModeChange()
    }
    
    public func fetchProduct(sku: String) async throws -> StoreProductInfo {
        try await storeKitHandler.fetchProduct(sku: sku)
    }
}

extension CourseUpgradeHandler {
    // IAP error messages

    fileprivate func error(message: String) -> Error {
        return NSError(domain: "edx.app.courseupgrade", code: 1010, userInfo: [NSLocalizedDescriptionKey: message])
    }
    
    fileprivate func unverifiedCourseError() -> Error {
        return NSError(
            domain: "edx.app.courseupgrade",
            code: 409,
            userInfo: [NSLocalizedDescriptionKey: CoreLocalization.CourseUpgrade.FailureAlert.courseNotFullfilled]
        )
    }
    
    fileprivate func emptyReceiptError() -> Error {
        return NSError(
            domain: "edx.app.courseupgrade",
            code: 402,
            userInfo: [NSLocalizedDescriptionKey: CoreLocalization.CourseUpgrade.FailureAlert.generalErrorMessage]
        )
    }
}

extension CourseUpgradeHandler {
    @MainActor
    public func resolveUnfinishedPayments(
        loggedInUserID: Int,
        coreAnalytics: CoreAnalytics
    ) async {
        let inProgressIAPs = CourseUpgradeHelper.getAllInProgressIAP(loggedInUserID: loggedInUserID)
        guard !inProgressIAPs.isEmpty else { return }
        
        for inprogressIAP in inProgressIAPs {
            do {
                let product = try await fetchProduct(sku: inprogressIAP.sku)
                await fulfillPurchase(
                    inprogressIAP: inprogressIAP,
                    product: product,
                    coreAnalytics: coreAnalytics
                )
            } catch {
                debugLog("⛔️⛔️⛔️⛔️⛔️", error)
            }
        }
    }
    
    public func fulfillPurchase(
        inprogressIAP: InProgressIAP,
        product: StoreProductInfo,
        coreAnalytics: CoreAnalytics
    ) async {
        coreAnalytics.trackCourseUnfulfilledPurchaseInitiated(
            courseID: inprogressIAP.courseID,
            pacing: inprogressIAP.pacing,
            screen: .dashboard,
            flowType: .silent
        )
        
        await upgradeCourse(
            sku: inprogressIAP.sku,
            mode: .silent,
            productInfo: product,
            pacing: inprogressIAP.pacing,
            courseID: inprogressIAP.courseID,
            lmsPrice: inprogressIAP.lmsPrice,
            componentID: nil,
            screen: .dashboard,
            completion: nil
        )
    }
}
