// The Swift Programming Language
// https://docs.swift.org/swift-book
import OEXFoundation
import SwiftUI

public class EDXIAPService: IAPServiceProtocol {
    public typealias Configuration = EDXIAPConfiguration
    public func courseButton(configuration: Configuration) -> AnyView {
        AnyView(
            EmptyView()
        )
    }

    let router: RouterProtocol = Router()
    public let style: EDXIAPStyle
    
    public init(style: EDXIAPStyle = .init()) {
        self.style = style
        
    }
    
    public func dashboardPrimaryCardButton(configuration: Configuration) -> AnyView {
        AnyView(
            PrimaryCardButton(style: style.dashboardButton, action: { [weak self] in
                guard let self else { return }
                self.router.navigateToUpgrade(style: self.style.upgradeInfoView, configuration: configuration)
            })
        )
    }
}
