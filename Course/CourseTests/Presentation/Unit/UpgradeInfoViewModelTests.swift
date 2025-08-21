//
//  UpgradeViewModelTests.swift
//  CourseTests
//
//  Created by Vadim Kuznetsov on 28.05.24.
//

import XCTest
@testable import Core
import SwiftyMocky

final class UpgradeInfoViewModelTests: XCTestCase {
    typealias FlowData = (sku: String, product: StoreProductInfo, currencyCode: String, receipt: String )
    
    enum UpgradeInfoViewModelTestsError: Error {
        case cantSetup
        case handlerIsNil
        case storeMockIsNil
        case interactorIsNil
        case routerIsNil
        case incorrectValuesReturned
    }
    
    var config: Config?
    var interactor: CourseUpgradeInteractorProtocolMock?
    var enrollmentInteractor: EnrollmentInteractorProtocolMock?
    var storeHandler: StoreKitHandlerProtocolMock?
    var helper: CourseUpgradeHelper?
    var handler: CourseUpgradeHandler?
    var router: BaseRouterMock?
    var storage: CoreStorageMock?
    
    override func setUpWithError() throws {
        config = ConfigMock()
        interactor = CourseUpgradeInteractorProtocolMock()
        enrollmentInteractor = EnrollmentInteractorProtocolMock()
        storeHandler = StoreKitHandlerProtocolMock()
        storage = CoreStorageMock()
        let analytics = CoreAnalyticsMock()
        
        router = BaseRouterMock()
        guard let config, let interactor, let enrollmentInteractor, let storeHandler, let router, let storage else { throw UpgradeInfoViewModelTestsError.cantSetup }
        
        helper = CourseUpgradeHelper(config: config, analytics: analytics, router: router, storage: storage)
        
        guard let helper else { throw UpgradeInfoViewModelTestsError.cantSetup }
        handler = CourseUpgradeHandler(
            config: config,
            interactor: interactor,
            enrollmentInteractor: enrollmentInteractor,
            storeKitHandler: storeHandler,
            helper: helper
        )

        Given(enrollmentInteractor, .getEnrollmentDetails(courseID: .any, willReturn: enrollmentDetails(mode: .audit)))
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        config = nil
        interactor = nil
        storeHandler = nil
        helper = nil
        handler = nil
    }

    private func setupForSuccessFetch(sku: String, product: StoreProductInfo) throws {
        guard let storeHandler else { throw UpgradeInfoViewModelTestsError.storeMockIsNil }
        Given(storeHandler, .fetchProduct(sku: .value(sku), willReturn: product))
    }
    
    private func setupForFailureFetch(sku: String, error: Error) throws {
        guard let storeHandler else { throw UpgradeInfoViewModelTestsError.storeMockIsNil }
        Given(storeHandler, .fetchProduct(sku: .value(sku), willThrow: UpgradeError.productNotExist))
    }
    
    private func verifyFetchProduct() throws {
        guard let storeHandler else { throw UpgradeInfoViewModelTestsError.storeMockIsNil }
        Verify(storeHandler, 1, .fetchProduct(sku: .any))
    }
    
    private func viewModel(with handler: CourseUpgradeHandlerProtocol) throws -> UpgradeInfoViewModel {
        return UpgradeInfoViewModel(
            productName: "TestProduct", 
            message: "Message",
            sku: "sku1",
            courseID: "course1",
            screen: .dashboard,
            handler: handler,
            pacing: Pacing.selfPace.rawValue,
            analytics: CoreAnalyticsMock(),
            router: router ?? BaseRouterMock(),
            lmsPrice: .zero
        )
    }
    
    private func enrollmentDetails(mode: DataLayer.Mode) -> EnrollmentDetails {
        return EnrollmentDetails(
            id: "course1",
            discussionURL: nil,
            enrollmentMetadata: EnrollmentMetadata(
                created: "2025-07-25T11:50:18Z",
                mode: mode,
                isActive: true,
                upgradeDeadline: nil
            ),
            coursewareAccess: CoursewareAccess(
                hasAccess: false,
                errorCode: .notStarted,
                developerMessage: "Course does not start until 2025-07-15 04:00:00+00:00",
                userMessage: "Course does not start until July 15, 2025",
                additionalContextUserMessage: nil,
                userFragment: nil
            )
        )
    }
    
    private func productInfo() -> StoreProductInfo {
        let price = NSDecimalNumber(decimal: 99)
        let localizedPrice: String? = "test localized price"
        let currencyCode: String? = "USD"

        return StoreProductInfo(
            price: price,
            localizedPrice: localizedPrice,
            currencyCode: currencyCode
        )
    }
    
    func testFetchProductSuccess() async throws {
        guard let handler else { throw UpgradeInfoViewModelTestsError.handlerIsNil }
        let viewModel = try self.viewModel(with: handler)

        let product = productInfo()
        try setupForSuccessFetch(sku: viewModel.sku, product: product)
        
        await viewModel.fetchProduct()
        try verifyFetchProduct()
        XCTAssertEqual(viewModel.product?.price, product.price)
        XCTAssertEqual(viewModel.product?.localizedPrice, product.localizedPrice)
        XCTAssertEqual(viewModel.product?.currencyCode, product.currencyCode)
    }
    
    func testFetchProductFailure() async throws {
        guard let handler else { throw UpgradeInfoViewModelTestsError.handlerIsNil }
        let viewModel = try self.viewModel(with: handler)

        
        let error = UpgradeError.productNotExist
        try setupForFailureFetch(sku: viewModel.sku, error: error)
        
        await viewModel.fetchProduct()
        try verifyFetchProduct()
        XCTAssertTrue(viewModel.product == nil)
        guard let router else { throw UpgradeInfoViewModelTestsError.routerIsNil }
        Verify(router, 1, .presentNativeAlert(title: .any, message: .any, actions: .any))
    }

    private func prepareSuccessFlow(for sku: String, product: StoreProductInfo, courseRunKey: String) throws -> FlowData {
        guard let enrollmentInteractor else { throw UpgradeInfoViewModelTestsError.cantSetup }

        // 1st call -> audit, 2nd+ -> verified
        Given(
            enrollmentInteractor,
            .getEnrollmentDetails(
                courseID: .any,
                willReturn: enrollmentDetails(mode: .audit),
                enrollmentDetails(mode: .verified)
            )
        )

        guard let interactor else { throw UpgradeInfoViewModelTestsError.interactorIsNil }
        
        guard let storeHandler else { throw UpgradeInfoViewModelTestsError.storeMockIsNil }
        let response = StoreKitUpgradeResponse(success: true, receipt: "Some receipt here")
        Given(storeHandler, .purchaseProduct(.value(sku), willReturn: response))
        
        guard let receipt = response.receipt,
              let currencyCode = product.currencyCode
        else { throw UpgradeInfoViewModelTestsError.incorrectValuesReturned }
        
        let order = FulfillOrder(orderId: "test_order_id", orderNumber: "test_order_number")
        Given(
            interactor, .createOrder(
                courseRunKey: .value(courseRunKey),
                currencyCode: .value(currencyCode),
                price: .value(product.price),
                receipt: .value(receipt),
                willReturn: order
            )
        )
        return (sku: sku, product: product, currencyCode: currencyCode, receipt: receipt)
    }
    
    @MainActor 
    private func verifySuccessFlow(flowData: FlowData, courseRunKey: String) throws {
        guard let interactor else { throw UpgradeInfoViewModelTestsError.interactorIsNil }
        
        guard let storeHandler else { throw UpgradeInfoViewModelTestsError.storeMockIsNil }
        Verify(storeHandler, 1, .purchaseProduct(.value(flowData.sku)))
        Verify(
            interactor,
            1,
            .createOrder(
                courseRunKey: .value(courseRunKey),
                currencyCode: .value(flowData.currencyCode),
                price: .value(flowData.product.price),
                receipt: .value(flowData.receipt)
            )
        )
        // Check router flow
        guard let router else { throw UpgradeInfoViewModelTestsError.routerIsNil }
        Verify(router, 1, .hideUpgradeInfo(animated: .any))
        Verify(router, 1, .showUpgradeLoaderView(animated: .any))
        Verify(router, 1, .hideUpgradeLoaderView(animated: .any))
    }

    func testUpgradeHandlerSuccess() async throws {
        guard let handler else { throw UpgradeInfoViewModelTestsError.handlerIsNil }
        let viewModel = try self.viewModel(with: handler)

        let product = productInfo()
        viewModel.product = product
        let flowData = try prepareSuccessFlow(for: viewModel.sku, product: product, courseRunKey: viewModel.courseID)
        
        await viewModel.purchase()
        
        // Verify purchase backend processing
        try await verifySuccessFlow(flowData: flowData, courseRunKey: viewModel.courseID)
        
        var stateIsSuccess: Bool = false
        if case .complete = handler.state {
            stateIsSuccess = true
        }
        XCTAssertTrue(stateIsSuccess)
        XCTAssertEqual(viewModel.isLoading, false)
        XCTAssertEqual(viewModel.interactiveDismissDisabled, false)
    }
    
    func testUpgradeHelperSuccess() async throws {
        let courseUpgradeHelper = CourseUpgradeHelperProtocolMock()
        guard let config, let interactor, let enrollmentInteractor, let storeHandler else { throw UpgradeInfoViewModelTestsError.cantSetup }
        let handler = CourseUpgradeHandler(
            config: config,
            interactor: interactor,
            enrollmentInteractor: enrollmentInteractor,
            storeKitHandler: storeHandler,
            helper: courseUpgradeHelper
        )
        
        let product = productInfo()
        let viewModel = try self.viewModel(with: handler)
        viewModel.product = product
        
        Given(courseUpgradeHelper, .isAllowedToPurchase(.any, courseID: .any, willReturn: true))
        
        let _ = try prepareSuccessFlow(for: viewModel.sku, product: product, courseRunKey: viewModel.courseID)
        await viewModel.purchase()
        
        Verify(
            courseUpgradeHelper,
            1,
            .setData(courseID: .value(viewModel.courseID),
                     pacing: .value(viewModel.pacing),
                     blockID: .value(nil),
                     localizedPrice: .value(product.price),
                     localizedCurrencyCode: .value(product.currencyCode),
                     lmsPrice: .value(.zero),
                     screen: .value(viewModel.screen)
                    )
        )
    }
    
    enum UknownTestError: Error {
        case unknown
    }
    
    @MainActor
    private func verifyFailureRouterFlow(flowData: FlowData) throws {
        // Check router flow
        guard let router else { throw UpgradeInfoViewModelTestsError.routerIsNil }
        Verify(router, 1, .hideUpgradeLoaderView(animated: .any))
        Verify(router, 1, .presentNativeAlert(title: .any, message: .any, actions: .any))
    }
    
    private func prepareFailurePurchaseFlow(for sku: String, product: StoreProductInfo) throws -> FlowData {
        guard let interactor else { throw UpgradeInfoViewModelTestsError.interactorIsNil }
        
        let response = StoreKitUpgradeResponse(success: false, receipt: nil, error: .paymentError(UknownTestError.unknown))
        guard let storeHandler else { throw UpgradeInfoViewModelTestsError.storeMockIsNil }
        Given(storeHandler, .purchaseProduct(.value(sku), willReturn: response))
        
        guard let currencyCode = product.currencyCode
        else { throw UpgradeInfoViewModelTestsError.incorrectValuesReturned }
        
        return (sku: sku, product: product, currencyCode: currencyCode, receipt: "")
    }
    
    private func verifyFailurePurchaseFlow(flowData: FlowData) throws {
        guard let storeHandler else { throw UpgradeInfoViewModelTestsError.storeMockIsNil }
        Verify(storeHandler, 1, .purchaseProduct(.value(flowData.sku)))
    }
    
    func testUpgradeHandlerPurchaseFailure() async throws {
        guard let handler else { throw UpgradeInfoViewModelTestsError.handlerIsNil }
        let viewModel = try self.viewModel(with: handler)

        let product = productInfo()
        viewModel.product = product
        let flowData = try prepareFailurePurchaseFlow(for: viewModel.sku, product: product)
        
        await viewModel.purchase()
        
        // Verify purchase backend processing
        try verifyFailurePurchaseFlow(flowData: flowData)
        try await verifyFailureRouterFlow(flowData: flowData)

        
        var stateIsSuccess: Bool = false
        if case .error = handler.state {
            stateIsSuccess = true
        }
        XCTAssertTrue(stateIsSuccess)
        XCTAssertEqual(viewModel.isLoading, false)
        XCTAssertEqual(viewModel.interactiveDismissDisabled, false)
    }
    
    private func prepareFailureFullfillOrderFlow(for sku: String, product: StoreProductInfo, courseRunKey: String) throws -> FlowData {
        guard let interactor else { throw UpgradeInfoViewModelTestsError.interactorIsNil }
        
        guard let storeHandler else { throw UpgradeInfoViewModelTestsError.storeMockIsNil }
        let response = StoreKitUpgradeResponse(success: true, receipt: "Some receipt here")
        Given(storeHandler, .purchaseProduct(.value(sku), willReturn: response))
        
        guard let receipt = response.receipt,
              let currencyCode = product.currencyCode
        else { throw UpgradeInfoViewModelTestsError.incorrectValuesReturned }
        
        Given(
            interactor, .createOrder(
                courseRunKey: .value(courseRunKey),
                currencyCode: .value(currencyCode),
                price: .value(product.price),
                receipt: .value(receipt),
                willThrow: UknownTestError.unknown
            )
        )
        
        return (sku: sku, product: product, currencyCode: currencyCode, receipt: receipt)
    }
    
    private func verifyFullfillOrderFlow(flowData: FlowData, courseRunKey: String) throws {
        guard let interactor else { throw UpgradeInfoViewModelTestsError.interactorIsNil }
        Verify(
            interactor,
            1,
            .createOrder(
                courseRunKey: .value(courseRunKey),
                currencyCode: .value(flowData.currencyCode),
                price: .value(flowData.product.price),
                receipt: .value(flowData.receipt)
            )
        )
    }
    
    func testFullfillOrderFailure() async throws {
        guard let handler else { throw UpgradeInfoViewModelTestsError.handlerIsNil }
        let viewModel = try self.viewModel(with: handler)

        let product = productInfo()
        viewModel.product = product
        let flowData = try prepareFailureFullfillOrderFlow(for: viewModel.sku, product: product, courseRunKey: viewModel.courseID)
        
        await viewModel.purchase()
        
        // Verify purchase backend processing
        try verifyFailurePurchaseFlow(flowData: flowData)
        try verifyFullfillOrderFlow(flowData: flowData, courseRunKey: viewModel.courseID)
        guard let router else { throw UpgradeInfoViewModelTestsError.routerIsNil }
        Verify(router, 1, .presentNativeAlert(title: .any, message: .any, actions: .any))

        
        var stateIsSuccess: Bool = false
        if case .error = handler.state {
            stateIsSuccess = true
        }
        XCTAssertTrue(stateIsSuccess)
        XCTAssertEqual(viewModel.isLoading, false)
        XCTAssertEqual(viewModel.interactiveDismissDisabled, false)
    }
}
