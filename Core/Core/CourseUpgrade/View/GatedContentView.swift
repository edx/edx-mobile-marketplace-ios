//
//  GatedContentView.swift
//  Course
//
//  Created by Shafqat Muneer on 6/18/25.
//

import SwiftUI
import Theme
import EDXFeatureManagement
import Swinject

public struct GatedContentView: View {
    @StateObject var viewModel: UpgradeInfoViewModel
    
    @State var size: CGSize = .zero
    @State private var isLandscape: Bool = false
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    public init(
        viewModel: UpgradeInfoViewModel
    ) {
        self._viewModel = .init(wrappedValue: viewModel)
    }
    
    private var shouldHideText: Bool {
        viewModel.isLoading && !viewModel.price.isEmpty
    }
    
    private var buttonText: String {
        shouldHideText ? "" : "\(CoreLocalization.CourseUpgrade.View.Button.upgradeNow) \(viewModel.price)"
    }
    
    private var shouldHideButton: Bool {
        viewModel.isLoading
    }
    
    private var buttonImage: Image? {
        Image(systemName: "lock.fill")
    }
    
    private var storage: CoreStorage? {
        let storage = Container.shared.resolve(CoreStorage.self)
        return storage
    }
        
    private var isiPad: Bool {
        return (verticalSizeClass == .regular && horizontalSizeClass == .regular)
    }

    private var shouldShowCertificatePreview: Bool {
        return viewModel.shouldShowCertificatePreview()
    }
    
    private var topOffSet: CGFloat {
        return isLandscape ? 78 : 68
    }
    
    private var portraitContentHorizontalPadding: CGFloat {
        return size.width <= 375 ? 12 : 24
    }
    
    private var portraitContentVerticalPadding: CGFloat {
        return size.width <= 375 ? 24 : 42
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                if isLandscape {
                    VStack(alignment: .leading, spacing: 0) {
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 0) {
                                HStack(alignment: .bottom) {
                                    CoreAssets.gatedImage.swiftUIImage
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 24, height: 24)
                                    
                                    Text(CoreLocalization.CourseUpgrade.View.gatedContentTitle)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .font(Theme.Fonts.titleMedium)
                                        .foregroundColor(Theme.Colors.textPrimary)
                                }
                                
                                Text(CoreLocalization.CourseUpgrade.View.gatedContentMessage)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .font(Theme.Fonts.bodyLarge)
                                    .foregroundColor(Theme.Colors.textPrimary)
                                    .padding(.top, 9)
                                    .padding(.bottom, 21)
                                
                                UpgradeOptionsView(image: CoreAssets.upgradeCheckmarkOutlinedImage.swiftUIImage)
                                    .foregroundColor(Theme.Colors.textPrimary)
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
                                .padding(.top, 20)
                                .padding(.horizontal, 24)
                                .padding(.bottom, 40)
                            }
                            .padding(.top, 42)
                            .padding(.bottom, 42)
                            if shouldShowCertificatePreview {
                                CertificateView(name: storage?.user?.username ?? "", courseName: viewModel.productName)
                                    .padding(.leading, isiPad ? 50 : 0)
                                    .padding(.trailing, isiPad ? 50 : 0)
                                    .padding(.top, 42)
                                    .padding(.bottom, 182)
                            }
                        }
                    }
                } else {
                    VStack(alignment: .leading, spacing: 0) {
                        HStack(alignment: .bottom) {
                            CoreAssets.gatedImage.swiftUIImage
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                            
                            Text(CoreLocalization.CourseUpgrade.View.gatedContentTitle)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(Theme.Fonts.titleMedium)
                                .foregroundColor(Theme.Colors.textPrimary)
                        }
                        
                        Text(CoreLocalization.CourseUpgrade.View.gatedContentMessage)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(Theme.Fonts.bodyLarge)
                            .foregroundColor(Theme.Colors.textPrimary)
                            .padding(.top, 9)
                            .padding(.bottom, 21)
                        
                        UpgradeOptionsView(image: CoreAssets.upgradeCheckmarkOutlinedImage.swiftUIImage)
                            .foregroundColor(Theme.Colors.textPrimary)
                    }
                    .padding(.horizontal, portraitContentHorizontalPadding)
                    .padding(.top, portraitContentVerticalPadding)

                    Spacer(minLength: 20)
                    if shouldShowCertificatePreview {
                        CertificateView(name: storage?.user?.username ?? "", courseName: viewModel.productName)
                            .padding(.leading, isiPad ? 150 : 20)
                            .padding(.trailing, isiPad ? 150 : 20)
                        Spacer(minLength: 20)
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
                    .padding(.horizontal, 24)
                    .padding(.bottom, 20)
                }
            }
        }
        .task {
            await viewModel.fetchProduct()
        }
        .onFirstAppear {
            viewModel.trackValuePropViewed()
        }
        .background(
            GeometryReader { geometry in
                Color.clear
                    .onAppear {
                        isLandscape = geometry.size.width > geometry.size.height
                        size = geometry.size
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
    GatedContentView(
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
        )
    )
}
#endif
