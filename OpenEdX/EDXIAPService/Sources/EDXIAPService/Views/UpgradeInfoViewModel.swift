//
//  UpgradeInfoViewModel.swift
//  EDXIAPService
//
//  Created by Vadim Kuznetsov on 20.03.25.
//
import UIKit

class UpgradeInfoViewModel: ObservableObject, @unchecked Sendable {
    // NEEDS WORK let handler: CourseUpgradeHandlerProtocol
    // NEEDS WORK let analytics: Analytics
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
    
    var info: EDXProductInfo?

    public init(
        edxProduct: EDXProduct,
        helper: EDXIAPHelperProtocol,
        message: String = "",
        // NEEDS WORK handler: CourseUpgradeHandlerProtocol,
        // NEEDS WORK analytics: Analytics,
        router: RouterProtocol
    ) {
        self.edxProduct = edxProduct
        self.message = message
        // NEEDS WORK self.handler = handler
        // NEEDS WORK self.analytics = analytics
        self.router = router
        self.helper = helper
    }
    
    @MainActor
    public func fetchProduct() async {
        isLoading = true
        do {
            let info = try await helper.info(for: edxProduct)
            self.info = info
            guard !info.sku.isEmpty else {
                isLoading = false
                return
            }
            // NEEDS WORK product = try await handler.fetchProduct(sku: info.sku)
            isLoading = false
        } catch let error {
            showPriceLoadError(error: error)
        }
    }
    
    @MainActor
    private func showPriceLoadError(error: Error) {
        // NEEDS WORK
        /*
        guard let error = error as? UpgradeError else { return }

        analytics.trackCourseUpgradeLoadError(
            courseID: courseID,
            blockID: "",
            pacing: pacing,
            screen: screen
        )
        
        var actions: [UIAlertAction] = []
        
        if error != .productNotExist {
            actions.append(
                UIAlertAction(
                    title: CoreLocalization.CourseUpgrade.FailureAlert.priceFetchError,
                    style: .default
                ) {[weak self] _ in
                    guard let self else { return }
                    Task {
                        await self.fetchProduct()
                    }
                    
                    self.analytics.trackCourseUpgradeErrorAction(
                        courseID: self.courseID,
                        blockID: "",
                        pacing: pacing,
                        localizedPrice: nil,
                        localizedCurrencyCode: nil,
                        lmsPrice: lmsPrice,
                        screen: self.screen,
                        alertType: .priceFetch,
                        errorAction: UpgradeErrorAction.reloadPrice.rawValue,
                        error: "price",
                        flowType: .userInitiated
                    )
                }
            )
        }

        let cancelButtonTitle = error == .productNotExist ? CoreLocalization.ok : CoreLocalization.Alert.cancel
        actions.append(
            UIAlertAction(
                title: cancelButtonTitle,
                style: .default
            ) { [weak self] _ in
                guard let self else { return }
                self.error = error
                self.isLoading = false
                self.analytics.trackCourseUpgradeErrorAction(
                    courseID: self.courseID,
                    blockID: "",
                    pacing: pacing,
                    localizedPrice: nil,
                    localizedCurrencyCode: product?.currencySymbol,
                    lmsPrice: lmsPrice,
                    screen: self.screen,
                    alertType: .priceFetch,
                    errorAction: UpgradeErrorAction.close.rawValue,
                    error: "price",
                    flowType: .userInitiated
                )
            }
        )
        router.presentNativeAlert(
            title: CoreLocalization.CourseUpgrade.FailureAlert.alertTitle,
            message: CoreLocalization.CourseUpgrade.FailureAlert.priceFetchErrorMessage,
            actions: actions
        )
         */
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
        // NEEDS WORK
        /*
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
         */
    }
    
    func trackValuePropViewed() {
        // NEEDS WORK
//        analytics.trackValuePropViewed(
//            courseID: courseID,
//            pacing: pacing,
//            lmsPrice: lmsPrice,
//            screen: screen
//        )
    }
}
