//
//  Router.swift
//  EDXIAPService
//
//  Created by Vadim Kuznetsov on 4.03.25.
//
import OEXFoundation
import SwiftUI

class Router: RouterProtocol {
    func navigateToUpgrade(style: EDXUpgradeInfoViewStyle, product: EDXProduct, helper: EDXIAPHelperProtocol) {
        let topController = UIApplication.topViewController()
        let controller = UIHostingController(
            rootView: UpgradeInfoSheetView(
                style: style,
                product: product
            )
        )
        if let sheet = controller.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersEdgeAttachedInCompactHeight = true
            sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
            sheet.prefersGrabberVisible = true
        }

        topController?.present(controller, animated: true)

        /*
        let view = UpgradeInfoSheetView(
            viewModel: Container.shared.resolve(
                UpgradeInfoViewModel.self,
                arguments: productName, message, sku, courseID, screen, pacing, lmsPrice
            )!
        )
        let controller = UIHostingController(rootView: view)
        if let sheet = controller.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersEdgeAttachedInCompactHeight = true
            sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
            sheet.prefersGrabberVisible = true
        }
        navigationController.present(controller, animated: true) {
            continuation.resume()
        }
         */
    }
}
