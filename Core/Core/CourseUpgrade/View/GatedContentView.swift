//
//  GatedContentView.swift
//  Course
//
//  Created by Shafqat Muneer on 6/18/25.
//

import SwiftUI
import Theme
import Swinject

public struct GatedContentView: View {
    @StateObject var viewModel: UpgradeInfoViewModel
    @State var reader: GeometryProxy
    @State var size: CGSize = .zero
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private var isLandscape: Bool {
        return reader.size.width > reader.size.height
    }
    
    public init(
        viewModel: UpgradeInfoViewModel,
        reader: GeometryProxy
    ) {
        self._viewModel = .init(wrappedValue: viewModel)
        self._reader = .init(wrappedValue: reader)
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
            if shouldShowCertificatePreview {
                viewModel.trackCertificateShown()
            }
        }
        .background(
            GeometryReader { geometry in
                Color.clear
                    .onAppear {
                        size = geometry.size
                    }
            }
        )
    }
}

#if DEBUG
#Preview {
    GeometryReader { previewProxy in
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
                certificatePreviewExperimentManager: CertificatePreviewManagingMock(),
                router: BaseRouterMock(),
                lmsPrice: .zero
            ),
            reader: previewProxy
        )
    }
}
#endif
