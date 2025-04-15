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

protocol Analytics {
    func trackCourseUpgradeLoadError(
        courseID: String,
        blockID: String?,
        pacing: String,
        screen: EDXScreen
    )
    
    // swiftlint:disable:next function_parameter_count
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

public class EDXIAPService: IAPServiceProtocol, EDXIAPHelperProtocol {
    public typealias Product = EDXProduct
    public typealias ProductInfo = EDXProductInfo
    
    public let provider: OEXFoundation.IAPProductProvider<Product, ProductInfo>
    public let style: EDXIAPStyle
    public let analyticsFacade: EDXAnalyticsProtocol
    let validator: EDXReceiptValidator = .init()

    let router: RouterProtocol = Router()

    public init(
        provider: OEXFoundation.IAPProductProvider<Product, ProductInfo>,
        style: EDXIAPStyle = EDXIAPStyle(),
        analyticsFacade: EDXAnalyticsProtocol
    ) {
        self.provider = provider
        self.style = style
        self.analyticsFacade = analyticsFacade
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
        // NEEDS WORK
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
        // NEEDS WORK
    }
    
    public func trackCourseUpgradeLoadError(
        courseID: String,
        blockID: String? = nil,
        pacing: String,
        screen: EDXScreen
    ) {
        // NEEDS WORK
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
        // NEEDS WORK
    }
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

    func addBasket(sku: String) async throws -> EDXBasket {
        try await networkService.request(AddBasketRequest(sku: sku))
    }
    
    func checkoutBasket(basketID: Int) async throws {
        _ = try await networkService.request(CheckoutRequest(basketID: basketID))
    }
    
    func fullfillCheckout(parameters: EDXFullfillParameters) async throws -> EDXReceiptStatus {
        try await networkService.request(FullfillCheckoutRequest(parameters: parameters))
    }
}
