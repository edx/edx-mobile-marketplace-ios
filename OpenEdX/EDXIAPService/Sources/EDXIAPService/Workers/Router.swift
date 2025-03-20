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
                product: product,
                viewModel: UpgradeInfoViewModel(
                    edxProduct: product,
                    helper: helper,
                    // NEEDS WORK handler: <#T##any CourseUpgradeHandlerProtocol#>,
                    // NEEDS WORK analytics: <#T##any Analytics#>,
                    router: self
                )
            )
        )
        if let sheet = controller.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersEdgeAttachedInCompactHeight = true
            sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
            sheet.prefersGrabberVisible = true
        }

        topController?.present(controller, animated: true)
    }
    
    func presentNativeAlert(title: String?, message: String?, actions: [UIAlertAction]) {
        // NEEDS WORK
    }
}
