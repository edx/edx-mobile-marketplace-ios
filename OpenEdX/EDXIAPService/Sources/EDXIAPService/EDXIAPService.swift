// The Swift Programming Language
// https://docs.swift.org/swift-book
import OEXFoundation
import SwiftUI

public enum EDXScreen: Sendable {
    case dashboard
    case course
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

public class EDXIAPService: IAPServiceProtocol {
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
    
    public func buy(product: Product) {}
    
    public func view(for object: Any) -> AnyView? {
        guard let product = product(for: object) else { return nil }
        return AnyView(
            PrimaryCardButton(style: style.dashboardButton, action: { [weak self] in
                guard let self else { return }
                self.router.navigateToUpgrade(style: self.style.upgradeInfoView, product: product)
            })
        )
        
    }
}
