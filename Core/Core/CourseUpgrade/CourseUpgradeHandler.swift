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
    case basket
    case checkout
    case payment
    case verify
    case complete
    case error(UpgradeError)
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

public class CourseUpgradeHandler: CourseUpgradeHandlerProtocol {
    static var ecommerceURL: String = ""
    
    private var completion: UpgradeCompletionHandler?
    private var basketID: Int = 0
    private(set) var courseSku: String?
    private(set) var upgradeMode: UpgradeMode = .userInitiated
    private(set) var productInfo: StoreProductInfo?
    private var interactor: CourseUpgradeInteractorProtocol
    private var storeKitHandler: StoreKitHandlerProtocol
    private let helper: CourseUpgradeHelperProtocol
    private var courseID: String = ""
    private var lmsPrice: Double?
    private var componentID: String?
    private var screen: CourseUpgradeScreen?

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
        case .basket, .checkout, .payment:
            return .payment
        case .verify:
            return .fulfillment(showLoader: upgradeMode.isUserInitiated)
        case .complete:
            return .success(courseID, componentID, screen)
        case .error(let error):
            return .error(error)
        }
    }

    public init(
        config: ConfigProtocol,
        interactor: CourseUpgradeInteractorProtocol,
        storeKitHandler: StoreKitHandlerProtocol,
        helper: CourseUpgradeHelperProtocol
    ) {
        self.interactor = interactor
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
        
        helper.setData(
            courseID: courseID,
            pacing: pacing,
            blockID: componentID,
            localizedPrice: productInfo.price,
            localizedCurrencyCode: productInfo.currencySymbol,
            lmsPrice: lmsPrice,
            screen: screen
        )
        state = .initial
        await proceedWithUpgrade(sku: sku)
    }
    
    @MainActor
    private func proceedWithUpgrade(sku: String) async {
        state = .basket
        
        do {
            let basket = try await interactor.addBasket(sku: sku)
            basketID = basket.basketID
            await checkout(basketID: basketID, sku: sku)
            
        } catch let error {
            state = .error(.basketError(error))
        }
    }
    
    @MainActor
    private func checkout(basketID: Int, sku: String) async {
        // Checkout API
        guard basketID > 0 else {
            state = .error(.checkoutError(error(message: "invalid basket id < zero")))
            return
        }
        
        state = .checkout
        do {
            _ = try await interactor.checkoutBasket(basketID: basketID)
            if !upgradeMode.isUserInitiated {
                await reverifyPayment()
            } else {
                let response = await makePayment(sku: sku)
                await verifyResponse(response)
            }
            
        } catch let error {
            state = .error(.checkoutError(error))
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
        
        do {
            try await interactor.fulfillCheckout(
                basketID: basketID,
                price: productInfo?.price ?? 0.0,
                currencyCode: productInfo?.currencySymbol ?? "",
                receipt: receipt
            )
            state = .complete
            
        } catch let error {
            state = .error(.verifyReceiptError(error))
        }
    }
    
    // Give an option of retry to learner
    func reverifyPayment() async {
        let response = await storeKitHandler.purchaseReceipt()
        await verifyResponse(response)
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
}
