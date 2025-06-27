//
//  GatedContentView.swift
//  Course
//
//  Created by Shafqat Muneer on 6/18/25.
//

import SwiftUI
import Theme

public struct GatedContentView: View {
    @StateObject var viewModel: UpgradeInfoViewModel
    
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
    
    public var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    HStack(alignment: .bottom) {
                        CoreAssets.gatedImage.swiftUIImage
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                        
                        Text(CoreLocalization.CourseUpgrade.View.gatedContentTitle)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(Theme.Fonts.titleMedium)
                    }
                    
                    Text(CoreLocalization.CourseUpgrade.View.gatedContentMessage)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(Theme.Fonts.bodyLarge)
                        .padding(.top, 9)
                        .padding(.bottom, 21)
                    
                    UpgradeOptionsView(image: CoreAssets.upgradeCheckmarkOutlinedImage.swiftUIImage)
                        .foregroundColor(Theme.Colors.textPrimary)
                }
                .padding(.horizontal, 24)
                .padding(.top, 42)
                
                Spacer(minLength: 20)
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
            router: BaseRouterMock(),
            lmsPrice: .zero
        )
    )
}
#endif
