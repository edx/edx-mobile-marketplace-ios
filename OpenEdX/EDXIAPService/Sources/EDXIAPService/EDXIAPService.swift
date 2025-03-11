// The Swift Programming Language
// https://docs.swift.org/swift-book
import OEXFoundation
import SwiftUI

public class EDXIAPService: IAPServiceProtocol {
    public func courseButton(configuration: EDXIAPConfiguration) -> AnyView {
        AnyView(
            EmptyView()
        )
    }
    
    public typealias Configuration = EDXIAPConfiguration
    
    let router: RouterProtocol = Router()
    public let style: EDXIAPStyle
    
    public init(style: EDXIAPStyle = .init()) {
        self.style = style
        
    }
    
    public func dashboardPrimaryCardButton(configuration: EDXIAPConfiguration) -> AnyView {
        AnyView(
            PrimaryCardButton(style: style.dashboardButton, action: { [weak self] in
                guard let self else { return }
                self.router.navigateToUpgrade(style: self.style.upgradeInfoView, configuration: configuration)
            })
        )
    }
    
    public func configuration(
        productName: String,
        message: String,
        sku: String,
        courseID: String,
        isSelfPaced: Bool,
        lmsPrice: Double
    ) -> IAPConfiguration {
        EDXIAPConfiguration(
            productName: productName,
            message: message,
            sku: sku,
            courseID: courseID,
            isSelfPaced: isSelfPaced,
            lmsPrice: lmsPrice
        )
    }
}
