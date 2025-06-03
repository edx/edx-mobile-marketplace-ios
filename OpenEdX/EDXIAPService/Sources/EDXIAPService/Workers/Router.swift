//
//  Router.swift
//  EDXIAPService
//
//  Created by Vadim Kuznetsov on 4.03.25.
//
import OEXFoundation
import SwiftUI

class Router: RouterProtocol {
    private weak var snackBarView: UIView?
    
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
    
    @MainActor
    func showSnackbar(animated: Bool, style: EDXIAPStyle) async {
        await self.hideSnackbar(animated: false)
        let view = PaymentSnakbarView(style: style)
        let controller = UIHostingController(rootView: view)
        guard let topController = UIApplication.topViewController()?.mostTopViewController(),
              let superView = topController.view,
              let snackView = controller.view
        else { return }
        snackView.isUserInteractionEnabled = false
        snackView.backgroundColor = .clear
        snackView.translatesAutoresizingMaskIntoConstraints = false
        superView.addSubview(snackView)
        snackView.leadingAnchor.constraint(equalTo: superView.leadingAnchor).isActive = true
        snackView.trailingAnchor.constraint(equalTo: superView.trailingAnchor).isActive = true
        let bottomConstraint = snackView.bottomAnchor.constraint(equalTo: superView.bottomAnchor)
        bottomConstraint.isActive = true
        let snackSize = snackView.sizeThatFits(CGSize(width: superView.frame.size.width, height: .infinity))
        bottomConstraint.constant = snackSize.height
        superView.layoutIfNeeded()
        snackBarView = snackView
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            bottomConstraint.constant = 0
            superView.layoutIfNeeded()
        }) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + Assets.Timeouts.snackbarMessageLongTimeout) {
                Task {
                    await self.hideSnackbar(animated: animated)
                }
            }
        }
    }
    
    @MainActor
    func hideSnackbar(animated: Bool) async {
        guard let snackBarView, let superView = snackBarView.superview else { return }
        if animated {
            let constraint = superView.constraints.first(
                where: {
                    ($0.firstItem as? NSObject) == snackBarView && $0.firstAttribute == .bottom
                }
            )
            let snackSize = snackBarView.sizeThatFits(CGSize(width: superView.frame.size.width, height: .infinity))
            superView.layoutIfNeeded()
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
                constraint?.constant = snackSize.height
                superView.layoutIfNeeded()
            }) { _ in
                snackBarView.removeFromSuperview()
                self.snackBarView = nil
            }
        } else {
            snackBarView.removeFromSuperview()
            self.snackBarView = nil
        }
    }
}
