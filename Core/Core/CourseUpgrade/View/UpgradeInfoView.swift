//
//  UpgradeInfoView.swift
//  Core
//
//  Created by Vadim Kuznetsov on 11.06.24.
//

import SwiftUI
import Theme
import Swinject
import EDXFeatureManagement

public struct UpgradeInfoView<Content>: View where Content: View {
    let isFindCourseButtonVisible: Bool
    private let headerView: () -> Content
    private let findAction: (() -> Void)?
    private var storage: CoreStorage? {
        let storage = Container.shared.resolve(CoreStorage.self)
        return storage
    }
    @StateObject var viewModel: UpgradeInfoViewModel
    @State private var isLandscape: Bool = false
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    public init(
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
        shouldHideText ? "" : "\(CoreLocalization.CourseUpgrade.View.Button.upgradeNow) \(viewModel.price)"
    }
    
    private var buttonImage: Image? {
        shouldHideText ? nil : Image(systemName: "lock.fill")
    }
    
    private var isiPad: Bool {
        return (verticalSizeClass == .regular && horizontalSizeClass == .regular)
    }
    
    private var shouldShowCertificatePreview: Bool {
        return viewModel.shouldShowCertificatePreview()
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                headerView()
                VStack(alignment: .leading, spacing: 20) {
                    if isLandscape {
                        HStack(alignment: .top) {
                            VStack(alignment: .leading) {
                                if !viewModel.productName.isEmpty {
                                    Text("\(CoreLocalization.CourseUpgrade.View.title) \(viewModel.productName)")
                                        .font(Theme.Fonts.titleLarge)
                                }
                                UpgradeOptionsView()
                                    .foregroundColor(Theme.Colors.textPrimary)
                                Spacer(minLength: 20)
                                if isFindCourseButtonVisible {
                                    StyledButton(
                                        CoreLocalization.CourseUpgrade.Button.findCourse,
                                        action: {
                                            findAction?()
                                        },
                                        color: Theme.Colors.background,
                                        textColor: Theme.Colors.accentButtonColor,
                                        borderColor: Theme.Colors.accentButtonColor
                                    )
                                    .frame(height: 42)
                                    .padding(.horizontal, 20)
                                    .padding(.bottom, 20)
                                }
                                ZStack {
                                    if viewModel.error == nil && !viewModel.sku.isEmpty {
                                        StyledButton(
                                            buttonText,
                                            action: {
                                                Task {
                                                    await viewModel.purchase()
                                                }
                                            },
                                            color: Theme.Colors.accentButtonColor,
                                            textColor: Theme.Colors.styledButtonText,
                                            leftImage: buttonImage,
                                            imagesStyle: .attachedToText,
                                            isTitleTracking: false,
                                            isLimitedOnPad: false
                                        )
                                        .opacity(shouldHideButton ? 0 : 1)
                                        .disabled(viewModel.isLoading)
                                                                                
                                        ProgressBar(size: 30, lineWidth: 8)
                                            .opacity(viewModel.isLoading ? 1 : 0)
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.bottom, 20)
                            }
                            if shouldShowCertificatePreview {
                                CertificateView(name: storage?.user?.username ?? "", courseName: viewModel.productName)
                                    .padding(.leading, isiPad ? 50 : 0)
                                    .padding(.trailing, isiPad ? 50 : 0)
                            }
                        }
                    } else {
                        if !viewModel.productName.isEmpty {
                            Text("\(CoreLocalization.CourseUpgrade.View.title) \(viewModel.productName)")
                                .font(Theme.Fonts.titleLarge)
                        }
                        UpgradeOptionsView()
                            .foregroundColor(Theme.Colors.textPrimary)
                        if shouldShowCertificatePreview {
                            CertificateView(name: storage?.user?.username ?? "", courseName: viewModel.productName)
                                .padding(.leading, isiPad ? 150 : 0)
                                .padding(.trailing, isiPad ? 150 : 0)
                            Spacer(minLength: 20)
                        }
                        if isFindCourseButtonVisible {
                            StyledButton(
                                CoreLocalization.CourseUpgrade.Button.findCourse,
                                action: {
                                    findAction?()
                                },
                                color: Theme.Colors.background,
                                textColor: Theme.Colors.accentButtonColor,
                                borderColor: Theme.Colors.accentButtonColor
                            )
                            .frame(height: 42)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 20)
                        }
                        ZStack {
                            if viewModel.error == nil && !viewModel.sku.isEmpty {
                                StyledButton(
                                    buttonText,
                                    action: {
                                        Task {
                                            await viewModel.purchase()
                                        }
                                    },
                                    color: Theme.Colors.accentButtonColor,
                                    textColor: Theme.Colors.styledButtonText,
                                    leftImage: buttonImage,
                                    imagesStyle: .attachedToText,
                                    isTitleTracking: false,
                                    isLimitedOnPad: false
                                )
                                .opacity(shouldHideButton ? 0 : 1)
                                .disabled(viewModel.isLoading)
                                .padding(.leading, isiPad ? 200 : 0)
                                .padding(.trailing, isiPad ? 200 : 0)
                                
                                ProgressBar(size: 30, lineWidth: 8)
                                    .opacity(viewModel.isLoading ? 1 : 0)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 30)
            }
        }
        .onFirstAppear {
            Task {
                await viewModel.fetchProduct()
            }
            viewModel.trackValuePropViewed()
            if shouldShowCertificatePreview {
                viewModel.trackCertificateShown()
            }
        }
        .background(
            GeometryReader { geometry in
                Color.clear
                    .onAppear {
                        isLandscape = geometry.size.width > geometry.size.height
                    }
                    .onChange(of: geometry.size) { newSize in
                        isLandscape = newSize.width > newSize.height
                    }
            }
        )
        
    }
}

#if DEBUG
#Preview {
    UpgradeInfoView(
        isFindCourseButtonVisible: true,
        viewModel: UpgradeInfoViewModel(
            productName: "Preview",
            message: "",
            sku: "SKU",
            courseID: "",
            screen: .dashboard,
            handler: CourseUpgradeHandlerProtocolMock(),
            pacing: "self",
            analytics: CoreAnalyticsMock(),
            certificatePreviewExperimentManager: FeatureManagerMock(),
            router: BaseRouterMock(),
            lmsPrice: .zero
        ),
        findAction: nil
    )
}
#endif
