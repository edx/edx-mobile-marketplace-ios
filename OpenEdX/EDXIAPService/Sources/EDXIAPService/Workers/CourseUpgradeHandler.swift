//
//  CourseUpgradeHandler.swift
//  EDXIAPService
//
//  Created by Vadim Kuznetsov on 21.03.25.
//
import Foundation

enum UpgradeCompletionState {
    case initial
    case payment
    case fulfillment(showLoader: Bool)
    case success(_ courseID: String, _ componentID: String?)
    case error(UpgradeError)
}

@MainActor
class CourseUpgradeHandler: CourseUpgradeHandlerProtocol {
    nonisolated(unsafe) static var ecommerceURL: String = ""
    
    private var completion: UpgradeCompletionHandler?
    private var basketID: Int = 0
    private(set) var courseSku: String?
    private(set) var upgradeMode: EDXUpgradeMode = .userInitiated
    private(set) var productInfo: StoreProductInfo?
    private var validator: EDXReceiptValidator
//    private var storeKitHandler: StoreKitHandlerProtocol // NEEDS WORK
//    private let helper: CourseUpgradeHelperProtocol // NEEDS WORK
    private var courseID: String = ""
    private var lmsPrice: Double?
    private var componentID: String?

    private(set) var state: UpgradeState = .initial {
        didSet {
            /* NEEDS WORK
            helper.handleCourseUpgrade(
                upgradeHadler: self,
                state: upgradeState,
                delegate: nil
            )
             */
            completion?(state)
        }
    }
    
    private var upgradeState: UpgradeCompletionState {
        switch state {
        case .initial:
            return .initial
        case .basket, .checkout, .payment:
            return .payment
        case .verify:
            return .fulfillment(showLoader: upgradeMode == .userInitiated)
        case .complete:
            return .success(courseID, componentID)
        case .error(let error):
            return .error(error)
        }
    }

    public init(
//        config: ConfigProtocol, // NEEDS WORK
        validator: EDXReceiptValidator
//        storeKitHandler: StoreKitHandlerProtocol, // NEEDS WORK
//        helper: CourseUpgradeHelperProtocol // NEEDS WORK
    ) {
        self.validator = validator
//        self.storeKitHandler = storeKitHandler // NEEDS WORK
//        self.helper = helper // NEEDS WORK
//        CourseUpgradeHandler.ecommerceURL = config.ecommerceURL ?? "" // NEEDS WORK
    }
    
    public func upgradeCourse(
        sku: String?,
        mode: EDXUpgradeMode = .userInitiated,
        productInfo: StoreProductInfo?,
        pacing: String,
        courseID: String,
        lmsPrice: Double,
        componentID: String?,
        screen: EDXScreen,
        completion: UpgradeCompletionHandler?
    ) async {
        self.completion = completion
        self.upgradeMode = mode
        self.courseID = courseID
        self.componentID = componentID
        self.productInfo = productInfo
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
        /* NEEDS WORK
        helper.setData(
            courseID: courseID,
            pacing: pacing,
            blockID: componentID,
            localizedPrice: productInfo.price,
            localizedCurrencyCode: productInfo.currencySymbol,
            lmsPrice: lmsPrice,
            screen: screen
        )
         */
        state = .initial
        await proceedWithUpgrade(sku: sku)
    }
    
    private func proceedWithUpgrade(sku: String) async {
        state = .basket
        
        do {
            let basket = try await validator.addBasket(sku: sku)
            basketID = basket.basketID
            await checkout(basketID: basketID, sku: sku)
            
        } catch let error {
            state = .error(.basketError(error))
        }
    }
    
    private func checkout(basketID: Int, sku: String) async {
        // Checkout API
        guard basketID > 0 else {
            state = .error(.checkoutError(error(message: "invalid basket id < zero")))
            return
        }
        
        state = .checkout
        do {
            try await validator.checkoutBasket(basketID: basketID)
            if upgradeMode != .userInitiated {
                await reverifyPayment()
            } else {
                /* NEEDS WORK
                let response = await makePayment(sku: sku)
                await verifyResponse(response)
                 */
            }
            
        } catch let error {
            state = .error(.checkoutError(error))
        }
    }
    /* NEEDS WORK
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
    */
    
    private func verifyPayment(_ receipt: String) async {
        state = .verify
        
        do {
            let parameters = EDXFullfillParameters(
                backedID: basketID,
                price: productInfo?.price ?? 0.0,
                currencyCode: productInfo?.currencySymbol ?? "",
                receipt: receipt
            )
            try await validator.fullfillCheckout(parameters: parameters)
            state = .complete
            
        } catch let error {
            state = .error(.verifyReceiptError(error))
        }
    }
    
    // Give an option of retry to learner
    func reverifyPayment() async {
        /* NEEDS WORK
        let response = await storeKitHandler.purchaseReceipt()
        await verifyResponse(response)
         */
    }
    
    public func fetchProduct(sku: String) async throws -> StoreProductInfo {
//        try await storeKitHandler.fetchProduct(sku: sku) // NEEDS WORK
        StoreProductInfo(price: .zero)// NEEDS WORK. Remove it.
    }
}

extension CourseUpgradeHandler {
    // IAP error messages

    fileprivate func error(message: String) -> Error {
        return NSError(domain: "edx.app.courseupgrade", code: 1010, userInfo: [NSLocalizedDescriptionKey: message])
    }
}
