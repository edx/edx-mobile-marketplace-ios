//
//  UpgradeInfoViewModel.swift
//  EDXIAPService
//
//  Created by Vadim Kuznetsov on 20.03.25.
//
import UIKit

class UpgradeInfoViewModel: ObservableObject, @unchecked Sendable {
    let handler: CourseUpgradeHandlerProtocol
    let analytics: EDXAnalyticsProtocol
    let router: RouterProtocol
    let edxProduct: EDXProduct
    let helper: EDXIAPHelperProtocol
    let message: String
    @Published var isLoading: Bool = false
    @Published var product: StoreProductInfo?
    @Published var error: Error?
    @Published var interactiveDismissDisabled: Bool = false
    var price: String {
        guard let product = product, let price = product.localizedPrice else { return "" }
        return price
    }
    
    var canShowUpgradeButton: Bool {
        product != nil && error == nil
    }
    
    var info: EDXProductInfo?

    public init(
        edxProduct: EDXProduct,
        helper: EDXIAPHelperProtocol,
        message: String = "",
        handler: CourseUpgradeHandlerProtocol,
        analytics: EDXAnalyticsProtocol,
        router: RouterProtocol
    ) {
        self.edxProduct = edxProduct
        self.message = message
        self.handler = handler
        self.analytics = analytics
        self.router = router
        self.helper = helper
    }
    
    @MainActor
    public func fetchProduct() async {
        guard product == nil else { return }
        isLoading = true
        do {
            let info = try await helper.info(for: edxProduct)
            self.info = info
            guard !info.sku.isEmpty else {
                isLoading = false
                return
            }
            analytics.trackValuePropViewed(
                courseID: info.courseID,
                pacing: info.isSelfPaced ? Pacing.selfPace.rawValue : Pacing.instructor.rawValue,
                lmsPrice: info.lmsPrice,
                screen: edxProduct.screen
            )
            product = try await handler.fetchProduct(sku: info.sku)
            isLoading = false
        } catch let error {
            showPriceLoadError(error: error)
        }
    }
    
    @MainActor
    private func showPriceLoadError(error: Error) {
        guard let error = error as? UpgradeError, let info else { return }

        let pacing = info.isSelfPaced ? Pacing.selfPace.rawValue : Pacing.instructor.rawValue
        analytics.trackCourseUpgradeLoadError(
            courseID: info.courseID,
            blockID: "",
            pacing: pacing,
            screen: edxProduct.screen
        )
        
        var actions: [UIAlertAction] = []
        
        if error != .productNotExist {
            actions.append(
                UIAlertAction(
                    title: Texts.CourseUpgrade.FailureAlert.priceFetchError,
                    style: .default
                ) {[weak self] _ in
                    guard let self else { return }
                    Task {
                        await self.fetchProduct()
                    }
                    
                    self.analytics.trackCourseUpgradeErrorAction(
                        courseID: info.courseID,
                        blockID: "",
                        pacing: pacing,
                        localizedPrice: nil,
                        localizedCurrencyCode: nil,
                        lmsPrice: info.lmsPrice,
                        screen: edxProduct.screen,
                        alertType: .priceFetch,
                        errorAction: UpgradeErrorAction.reloadPrice.rawValue,
                        error: "price",
                        flowType: .userInitiated
                    )
                }
            )
        }
        
        let cancelButtonTitle = error == .productNotExist ? Texts.ok : Texts.cancel
        actions.append(
            UIAlertAction(
                title: cancelButtonTitle,
                style: .default
            ) { [weak self] _ in
                guard let self else { return }
                self.error = error
                self.isLoading = false
                self.analytics.trackCourseUpgradeErrorAction(
                    courseID: info.courseID,
                    blockID: "",
                    pacing: pacing,
                    localizedPrice: nil,
                    localizedCurrencyCode: product?.currencySymbol,
                    lmsPrice: info.lmsPrice,
                    screen: edxProduct.screen,
                    alertType: .priceFetch,
                    errorAction: UpgradeErrorAction.close.rawValue,
                    error: "price",
                    flowType: .userInitiated
                )
            }
        )
        router.presentNativeAlert(
            title: Texts.CourseUpgrade.FailureAlert.alertTitle,
            message: Texts.CourseUpgrade.FailureAlert.priceFetchErrorMessage,
            actions: actions
        )
    }

    @MainActor
    public func purchase() async {
        isLoading = true
        guard let info else {
            isLoading = false
            return
        }
        let pacing = info.isSelfPaced ? Pacing.selfPace.rawValue : Pacing.instructor.rawValue
        interactiveDismissDisabled = true
        analytics.trackUpgradeNow(
            courseID: info.courseID,
            blockID: "",
            pacing: pacing,
            screen: edxProduct.screen,
            localizedPrice: product?.price,
            localizedCurrencyCode: product?.currencySymbol,
            lmsPrice: info.lmsPrice
        )
        
        await handler.upgradeCourse(
            sku: info.sku,
            mode: .userInitiated,
            productInfo: product,
            pacing: pacing,
            courseID: info.courseID,
            lmsPrice: info.lmsPrice,
            componentID: nil,
            screen: edxProduct.screen,
            completion: {[weak self] state in
                guard let self = self else { return }
                switch state {
                case .error:
                    DispatchQueue.main.async {
                        self.isLoading = false
                        self.interactiveDismissDisabled = false
                    }
                case .complete:
                    DispatchQueue.main.async {
                        self.isLoading = false
                        self.interactiveDismissDisabled = false
                    }
                default:
                    // NEEDS WORK
//                    debugLog("Upgrade state changed: \(state)")
                    break
                }
            }
        )
    }
}
