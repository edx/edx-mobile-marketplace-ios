//
//  UpgradeInfoView.swift
//  Core
//
//  Created by Vadim Kuznetsov on 11.06.24.
//

import SwiftUI
// NEEDS WORK import Theme

struct UpgradeInfoView<Content>: View where Content: View {
    let isFindCourseButtonVisible: Bool
    private let headerView: () -> Content
    private let findAction: (() -> Void)?
    @StateObject var viewModel: UpgradeInfoViewModel
    
    init(
        isFindCourseButtonVisible: Bool,
        image: Image? = nil,
        viewModel: UpgradeInfoViewModel,
        findAction: (() -> Void)? = nil,
        @ViewBuilder headerView: @escaping () -> Content = {EmptyView()}
    ) {
        self.isFindCourseButtonVisible = isFindCourseButtonVisible
        self._viewModel = .init(wrappedValue: viewModel)
        self.headerView = headerView
        self.findAction = findAction
    }
    
    private var shouldHideText: Bool {
        viewModel.isLoading && !viewModel.price.isEmpty
    }
    
    private var shouldHideButton: Bool {
        viewModel.isLoading
    }
    
    private var buttonText: String {
        // NEEDS WORK
        shouldHideText ? "" : ""// "\(CoreLocalization.CourseUpgrade.View.Button.upgradeNow) \(viewModel.price)"
    }
    
    private var buttonImage: Image? {
        shouldHideText ? nil : Image(systemName: "lock.fill")
    }
    // NEEDS WORK : Replace Assets to EDXStyle
    public var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                headerView()
                VStack(alignment: .leading, spacing: 20) {
                    if !viewModel.edxProduct.name.isEmpty {
                        Text("\(Texts.UpgradeInfo.title) \(viewModel.edxProduct.name)")
                            .font(Fonts.titleLarge.swiftUI())
                    }
                    
                    if !viewModel.message.isEmpty {
                        Text(viewModel.message)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(Fonts.bodyLarge.swiftUI())
                    }
                    
                    // NEEDS WORK : add style
//                    UpgradeOptionsView()
//                        .foregroundColor(Assets.Colors.textPrimary.swiftUI())
                }
                .padding(.horizontal, 20)
                .padding(.top, 30)
            }
            Spacer(minLength: 20)
            if isFindCourseButtonVisible {
                // NEEDS WORK : Move StyledButton
//                StyledButton(
//                    Texts.UpgradeInfo.Button.findCourse,
//                    action: {
//                        findAction?()
//                    },
//                    color: Assets.Colors.background,
//                    textColor: Theme.Colors.accentButtonColor,
//                    borderColor: Theme.Colors.accentButtonColor
//                )
//                .frame(height: 42)
//                .padding(.horizontal, 20)
//                .padding(.bottom, 20)
            }
            ZStack {
                if viewModel.error == nil && viewModel.info?.sku.isEmpty == false {
                    // NEEDS WORK : Move StyledButton
//                    StyledButton(
//                        buttonText,
//                        action: {
//                            Task {
//                                await viewModel.purchase()
//                            }
//                        },
//                        color: Theme.Colors.accentButtonColor,
//                        textColor: Theme.Colors.styledButtonText,
//                        leftImage: buttonImage,
//                        imagesStyle: .attachedToText,
//                        isTitleTracking: false,
//                        isLimitedOnPad: false
//                    )
//                    .opacity(shouldHideButton ? 0 : 1)
//                    .disabled(viewModel.isLoading)
                    
                    // NEEDS WORK
//                    ProgressBar(size: 30, lineWidth: 8, accentColor: <#Color#>)
//                        .opacity(viewModel.isLoading ? 1 : 0)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .task {
            await viewModel.fetchProduct()
        }
        .onFirstAppear {
            viewModel.trackValuePropViewed()
        }
    }
}

#if DEBUG
#Preview {
    // NEEDS WORK
//    UpgradeInfoView(
//        isFindCourseButtonVisible: true,
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
//        ),
//        findAction: nil
//    )
}
#endif
