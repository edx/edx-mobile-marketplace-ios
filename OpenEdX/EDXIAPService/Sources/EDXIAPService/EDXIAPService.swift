import OEXFoundation
import SwiftUI

public class EDXIAPService: IAPServiceProtocol, EDXIAPHelperProtocol {
    public typealias Product = EDXProduct
    public typealias ProductInfo = EDXProductInfo
    
    let config: EDXServiceConfig

    public let provider: OEXFoundation.IAPProductProvider<Product, ProductInfo>
    public let style: EDXIAPStyle
    public let analyticsFacade: EDXAnalyticsProtocol
    
    public let validator: EDXReceiptValidator
    let storeKitHandler: StoreKitHandlerProtocol = StorekitHandler()
    let courseUpgradeHelper: CourseUpgradeHelperProtocol

    let router: RouterProtocol = Router()

    public init(
        provider: OEXFoundation.IAPProductProvider<Product, ProductInfo>,
        style: EDXIAPStyle = EDXIAPStyle(),
        analyticsFacade: EDXAnalyticsProtocol,
        validator: EDXReceiptValidator,
        config: EDXServiceConfig
    ) {
        self.provider = provider
        self.style = style
        self.analyticsFacade = analyticsFacade
        self.validator = validator
        self.config = config
        self.courseUpgradeHelper = CourseUpgradeHelper(
            analytics: self.analyticsFacade,
            router: self.router,
            config: self.config,
            style: style
        )
    }
    
    public func product(for object: Any) -> Product? {
        provider.product(for: object)
    }
    
    public func info(for object: Any) async throws -> ProductInfo {
        var product: EDXProduct?
        if let object = object as? EDXProduct {
            product = object
        } else {
            product = provider.product(for: object)
        }
        
        guard let product = product else {
            throw EDXIAPError.cantGetProduct
        }

        return try await provider.requestInfo(for: product)
    }
    
    public func buy(product: Product) -> IAPPurchaseResult {
        // NEEDS WORK - remove purchase logic from handler and move it here.
        EDXPurchaseResult(isSuccess: true, receipt: nil, error: nil)
    }
    
    public func view(for object: Any) -> AnyView? {
        guard let product = product(for: object) else { return nil }
        let upgradeHandler = CourseUpgradeHandler(
            validator: validator,
            storeKitHandler: storeKitHandler,
            helper: courseUpgradeHelper
        )
        return AnyView(
            PrimaryCardButton(
                style: style,
                action: { [weak self] in
                    guard let self else { return }
                    self.router.navigateToUpgrade(
                        style: self.style,
                        product: product,
                        helper: self,
                        handler: upgradeHandler,
                        analyticsFacade: self.analyticsFacade
                    )
            })
        )
    }
}

extension EDXIAPService {
    enum EDXIAPError: Error {
        case cantGetProduct
    }
}
