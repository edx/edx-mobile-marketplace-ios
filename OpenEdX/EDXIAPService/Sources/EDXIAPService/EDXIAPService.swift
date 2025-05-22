// The Swift Programming Language
// https://docs.swift.org/swift-book
import OEXFoundation
import SwiftUI

public enum EDXScreen: String, Sendable {
    case dashboard
    case courseDashboard = "course_dashboard"
    case courseComponent = "course_component"
    case unknown
}

enum UpgradeState: Sendable {
    case initial
    case basket
    case checkout
    case payment
    case verify
    case complete
    case error(UpgradeError)
}

public enum EDXUpgradeMode: String, Sendable {
    case silent
    case userInitiated = "user_initiated"
    case restore
}

public enum EDXUpgradeAlertType: String {
    case priceFetch = "price_fetch"
    case basket
    case checkout
    case payment
    case execute
    case restore
    case unfulfilled
    case unknown
}

public enum Pacing: String {
    case selfPace = "self"
    case instructor
}

// These error actions are used to send in analytics
public enum UpgradeErrorAction: String {
    case refreshToRetry = "refresh"
    case reloadPrice = "reload_price"
    case emailSupport = "get_help"
    case close
}

public struct EDXProduct: IAPProduct {
    public var id: String
    public var name: String
    public var screen: EDXScreen
    public init(id: String, name: String, screen: EDXScreen) {
        self.id = id
        self.name = name
        self.screen = screen
    }
}

public enum EDXProviderError: Error {
    case cantObtainInfo
}

public struct EDXServiceConfigProtocol: Sendable {
    public var ecommerceURL: String
    public var paymentProcessor: String
    
    public init(ecommerceURL: String, paymentProcessor: String) {
        self.ecommerceURL = ecommerceURL
        self.paymentProcessor = paymentProcessor
    }
}

public class EDXIAPService: IAPServiceProtocol, EDXIAPHelperProtocol {
    public typealias Product = EDXProduct
    public typealias ProductInfo = EDXProductInfo
    
    public let provider: OEXFoundation.IAPProductProvider<Product, ProductInfo>
    public let style: EDXIAPStyle
    public let analyticsFacade: EDXAnalyticsProtocol
    private let config: EDXServiceConfigProtocol
    
    let validator: EDXReceiptValidator

    let router: RouterProtocol = Router()

    public init(
        provider: OEXFoundation.IAPProductProvider<Product, ProductInfo>,
        style: EDXIAPStyle = EDXIAPStyle(),
        analyticsFacade: EDXAnalyticsProtocol,
        config: EDXServiceConfigProtocol
    ) {
        self.provider = provider
        self.style = style
        self.analyticsFacade = analyticsFacade
        self.config = config
        self.validator = EDXReceiptValidator(config: config)
    }
    
    public func product(for object: Any) -> Product? {
        provider.product(for: object)
    }
    
    public func info(for product: EDXProduct) async throws -> ProductInfo {
        try await provider.requestInfo(for: product)
    }
    
    public func buy(product: Product) {}
    
    public func view(for object: Any) -> AnyView? {
        guard let product = product(for: object) else { return nil }
        return AnyView(
            PrimaryCardButton(
                style: style,
                action: { [weak self] in
                    guard let self else { return }
                    self.router.navigateToUpgrade(
                        style: self.style,
                        product: product,
                        helper: self,
                        handler: CourseUpgradeHandlerProtocolMock(), // NEEDS WORK
                        analyticsFacade: self.analyticsFacade
                    )
            })
        )
    }
}

@MainActor
protocol EDXIAPHelperProtocol {
    func product(for object: Any) -> EDXProduct?
    func info(for product: EDXProduct) async throws -> EDXProductInfo
}

struct EDXBasket: Sendable, Decodable {
    let success: String
    let basketID: Int
    
    public init(success: String, basketID: Int) {
        self.success = success
        self.basketID = basketID
    }
}

struct EDXReceiptStatus: Sendable, Decodable {
    let status: String
    
    public init(status: String) {
        self.status = status
    }
}

public struct EDXFullfillParameters {
    let backedID: Int
    let price: NSDecimalNumber
    let currencyCode: String
    let receipt: String
    
    public init(backedID: Int, price: NSDecimalNumber, currencyCode: String, receipt: String) {
        self.backedID = backedID
        self.price = price
        self.currencyCode = currencyCode
        self.receipt = receipt
    }
}

struct EDXReceiptValidator: Sendable {
    private let networkService: EDXNetworkService = DefaultNetworkService()
    private let config: EDXServiceConfigProtocol
    
    public init(config: EDXServiceConfigProtocol) {
        self.config = config
    }

    func addBasket(sku: String) async throws -> EDXBasket {
        try await networkService.request(AddBasketRequest(sku: sku, ecommerceURL: config.ecommerceURL))
    }
    
    func checkoutBasket(basketID: Int) async throws {
        _ = try await networkService.request(
            CheckoutRequest(
                basketID: basketID,
                ecommerceURL: config.ecommerceURL,
                paymentProcessor: config.paymentProcessor
            )
        )
    }
    
    func fullfillCheckout(parameters: EDXFullfillParameters) async throws -> EDXReceiptStatus {
        try await networkService.request(
            FullfillCheckoutRequest(
                parameters: parameters,
                ecommerceURL: config.ecommerceURL,
                paymentProcessor: config.paymentProcessor
            )
        )
    }
}
