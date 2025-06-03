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
    
    func backToRoot(animated: Bool) {
        UIApplication.topViewController()?.rootNavigationController()?.popToRootViewController(animated: animated)
    }
    
    @MainActor
    public func hideUpgradeLoaderView(animated: Bool) async {
        await withCheckedContinuation { continuation in
            if let controller = UIApplication.topViewController() as? UIHostingController<CourseUpgradeUnlockView> {
                controller.dismiss(animated: animated) {
                    continuation.resume()
                }
            } else {
                continuation.resume()
            }
        }
    }
    
    @MainActor
    public func hideUpgradeInfo(animated: Bool) async {
        await withCheckedContinuation { continuation in
            if let controller = UIApplication.topViewController() as?
                UIHostingController<UpgradeInfoSheetView> {
                controller.dismiss(animated: animated) {
                    continuation.resume()
                }
            } else {
                continuation.resume()
            }
        }
    }
    
    @MainActor
    public func showUpgradeLoaderView(animated: Bool, style: EDXIAPStyle) async {
        await withCheckedContinuation { continuation in
            let topController = UIApplication.topViewController()
            let unlockView = CourseUpgradeUnlockView(style: style)
            let controller = UIHostingController(rootView: unlockView)
            controller.modalTransitionStyle = .crossDissolve
            controller.modalPresentationStyle = .overFullScreen
            topController?.present(controller, animated: animated) {
                continuation.resume()
            }
        }
    }
}
