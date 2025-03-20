//
//  UpgradeInfoSheetView.swift
//  EDXIAPService
//
//  Created by Vadim Kuznetsov on 4.03.25.
//
import OEXFoundation
import SwiftUI

struct UpgradeInfoSheetView: View {
    @Environment(\.dismiss) private var dismiss
//    @ObservedObject var viewModel: UpgradeInfoViewModel
    let style: EDXUpgradeInfoViewStyle
    let product: EDXProduct
    let helper: EDXIAPHelperProtocol
    
    init(style: EDXUpgradeInfoViewStyle, product: EDXProduct, helper: EDXIAPHelperProtocol/*, viewModel: UpgradeInfoViewModel*/) {
//        self.viewModel = viewModel
        self.style = style
        self.product = product
        self.helper = helper
    }
    
    var body: some View {
        Text("Hello")
//        NavigationView {
//            UpgradeInfoView(
//                isFindCourseButtonVisible: false,
//                viewModel: viewModel
//            )
//            .background {
//                Theme.Colors.background
//                    .ignoresSafeArea()
//            }
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button {
//                        if !viewModel.interactiveDismissDisabled {
//                            dismiss()
//                        }
//                    } label: {
//                        Image(systemName: "xmark")
//                            .foregroundColor(Theme.Colors.accentColor)
//                    }
//                    .accessibilityIdentifier("close_button")
//                }
//            }
//        }
//        .navigationViewStyle(.stack)
//        .interactiveDismissDisabled(viewModel.interactiveDismissDisabled)
    }
}
//
//#if DEBUG
//#Preview {
//    UpgradeInfoSheetView(
//        viewModel: UpgradeInfoViewModel(
//            productName: "Preview",
//            message: "",
//            sku: "SKU",
//            courseID: "",
//            screen: .dashboard,
//            handler: CourseUpgradeHandlerProtocolMock(),
//            pacing: "self",
//            analytics: CoreAnalyticsMock(),
//            router: BaseRouterMock(),
//            lmsPrice: .zero
//        )
//    )
//}
//#endif
