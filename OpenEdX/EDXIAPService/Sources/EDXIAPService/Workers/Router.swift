//
//  Router.swift
//  EDXIAPService
//
//  Created by Vadim Kuznetsov on 4.03.25.
//
import OEXFoundation
import SwiftUI

class Router: RouterProtocol {
    func navigateToUpgrade(
        style: EDXIAPStyle,
        product: EDXProduct,
        helper: EDXIAPHelperProtocol,
        handler: CourseUpgradeHandlerProtocol,
        analyticsFacade: EDXAnalyticsProtocol
    ) {
        let topController = UIApplication.topViewController()
        let controller = UIHostingController(
            rootView: UpgradeInfoSheetView(
                style: style,
                product: product,
                viewModel: UpgradeInfoViewModel(
                    edxProduct: product,
                    helper: helper,
                    handler: handler,
                    analytics: analyticsFacade,
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
        guard let topController = UIApplication.topViewController() else { return }
        
        let alertController = UIAlertController().showAlert(
            withTitle: title,
            message: message,
            onViewController: topController) { _, _, _ in }
        for action in actions {
            alertController.addAction(action)
        }
    }
}
