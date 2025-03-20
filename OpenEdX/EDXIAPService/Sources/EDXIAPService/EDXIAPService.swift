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

enum UpgradeMode: String, Sendable {
    case silent
    case userInitiated = "user_initiated"
    case restore
}

enum UpgradeAlertType: String {
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
        alertType: UpgradeAlertType,
        errorAction: String,
        error: String,
        flowType: UpgradeMode
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

    let router: RouterProtocol = Router()

    public init(provider: OEXFoundation.IAPProductProvider<Product, ProductInfo>, style: EDXIAPStyle = EDXIAPStyle()) {
        self.provider = provider
        self.style = style
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
            PrimaryCardButton(style: style.dashboardButton, action: { [weak self] in
                guard let self else { return }
                self.router.navigateToUpgrade(style: self.style.upgradeInfoView, product: product, helper: self)
            })
        )
    }
}

@MainActor
protocol EDXIAPHelperProtocol {
    func product(for object: Any) -> EDXProduct?
    func info(for product: EDXProduct) async throws -> EDXProductInfo
}
