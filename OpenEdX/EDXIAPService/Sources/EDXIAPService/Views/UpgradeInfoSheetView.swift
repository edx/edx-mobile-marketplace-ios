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
    @ObservedObject var viewModel: UpgradeInfoViewModel
    let style: EDXUpgradeInfoViewStyle
    let product: EDXProduct
    
    init(
        style: EDXUpgradeInfoViewStyle,
        product: EDXProduct,
        viewModel: UpgradeInfoViewModel
    ) {
        self.viewModel = viewModel
        self.style = style
        self.product = product
    }
    
    var body: some View {
        NavigationView {
            // NEEDS WORK
//            UpgradeInfoView(
//                isFindCourseButtonVisible: false,
//                viewModel: viewModel
//            )
            // NEEDS WORK
//            .background {
//                 Theme.Colors.background
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
//                            // NEEDS WORK .foregroundColor(Theme.Colors.accentColor)
//                    }
//                    .accessibilityIdentifier("close_button")
//                }
//            }
        }
        .navigationViewStyle(.stack)
        .interactiveDismissDisabled(viewModel.interactiveDismissDisabled)
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
