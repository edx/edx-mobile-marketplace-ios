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

struct CertificateView: View {
    var name: String
    var courseName: String
    
    var body: some View {
        ZStack {
            CoreAssets.certificateBg.swiftUIImage
                .resizable()
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Theme.Colors.accentColor.opacity(0.2), lineWidth: 1)
                )
                            
            Text("PREVIEW")
                .font(Theme.Fonts.custom(.bold, 50.0))
                .foregroundColor(.gray)
                .opacity(0.2)
                .rotationEffect(.degrees(-45))
                .offset(x: 0, y: 0)
            
            HStack(alignment: .top) {
                // Left Column
                VStack(alignment: .leading) {
                    CoreAssets.verifiedCertificate.swiftUIImage
                        .resizable()
                        .frame(width: 70.0, height: 28.0)
                    Spacer()
                    VStack(alignment: .leading, spacing: 5.0, content: {
                        Text("This is to certify that")
                            .font(Theme.Fonts.custom(.regular, 8))
                            .foregroundStyle(Theme.Colors.certificateTextGrey)
                        Text(name)
                            .font(Theme.Fonts.custom(.bold, 22))
                            .foregroundStyle(Theme.Colors.certificateTitleTextColor)
                        
                        Text("has successfully completed all courses and received passing grades for a Verified Certificate in")
                            .font(Theme.Fonts.custom(.regular, 8))
                            .fixedSize(horizontal: false, vertical: true)
                            .multilineTextAlignment(.leading)
                            .lineLimit(2)
                            .foregroundStyle(Theme.Colors.certificateTextGrey)
                        
                        Text(courseName)
                            .font(Theme.Fonts.custom(.bold, 18))
                            .foregroundStyle(Theme.Colors.certificateTitleTextColor)
                        
                        Text("a course offered by Google, an online learning partnership between Google & edX.")
                            .font(Theme.Fonts.custom(.regular, 8))
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                            .lineLimit(2)
                            .foregroundStyle(Theme.Colors.certificateTextGrey)
                    })
                    
                    Spacer()
                    HStack {
                        HStack {
                            ThemeAssets.appLogo.swiftUIImage
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: 57.0, maxHeight: 41.0)
                                .colorMultiply(Theme.Colors.accentColor)
                        }
                        HStack(spacing: 10.0) {
                            VStack(alignment: .leading) {
                                Text("Verified Certificate")
                                    .font(Theme.Fonts.custom(.regular, 6))
                                    .foregroundStyle(Theme.Colors.certificateTextGrey)
                                Text("Issued August 2023")
                                    .font(Theme.Fonts.custom(.regular, 6))
                                    .foregroundStyle(Theme.Colors.certificateLightTextColor)
                            }
                            VStack(alignment: .leading) {
                                Text("Valid certificate ID:")
                                    .font(Theme.Fonts.custom(.regular, 6))
                                    .foregroundStyle(Theme.Colors.certificateTextGrey)
                                Text("1234567890")
                                    .font(Theme.Fonts.custom(.regular, 6))
                                    .foregroundStyle(Theme.Colors.certificateLightTextColor)
                            }
                        }
                    }
                }
                .padding(.leading, 10)
                .padding(.top, 30)
                
                // Right Column
                VStack(alignment: .trailing, spacing: 20) {
                    Spacer()
                    Image(systemName: "globe") // Replace with actual logo image
                        .resizable()
                        .frame(width: 20, height: 20)
                    
                    VStack(alignment: .trailing, spacing: 10.0) {
                        VStack(alignment: .trailing) {
                            CoreAssets.signatureCertificate.swiftUIImage
                                .padding(.bottom, 5)
                            Text("Maurilio Pugliesi")
                                .font(Theme.Fonts.custom(.regular, 8))
                                .foregroundStyle(Theme.Colors.certificateTextGrey)
                            Text("Professor")
                                .font(Theme.Fonts.custom(.regular, 8))
                                .foregroundStyle(Theme.Colors.certificateLightTextColor)
                            Text("University X")
                                .font(Theme.Fonts.custom(.regular, 8))
                                .foregroundStyle(Theme.Colors.certificateLightTextColor)
                            
                        }
                        
                        VStack(alignment: .trailing) {
                            CoreAssets.signatureCertificate.swiftUIImage
                                .padding(.bottom, 5)
                            Text("Justine Doe, Ph.D.")
                                .font(Theme.Fonts.custom(.regular, 8))
                                .foregroundStyle(Theme.Colors.certificateTextGrey)
                            Text("Professor")
                                .font(Theme.Fonts.custom(.regular, 8))
                                .foregroundStyle(Theme.Colors.certificateLightTextColor)
                            Text("University X")
                                .font(Theme.Fonts.custom(.regular, 8))
                                .foregroundStyle(Theme.Colors.certificateLightTextColor)
                        }
                        
                        VStack(alignment: .trailing) {
                            CoreAssets.signatureCertificate.swiftUIImage
                                .padding(.bottom, 5)
                            Text("Helga Svobodová")
                                .font(Theme.Fonts.custom(.regular, 8))
                                .foregroundStyle(Theme.Colors.certificateTextGrey)
                            Text("Professor")
                                .font(Theme.Fonts.custom(.regular, 8))
                                .foregroundStyle(Theme.Colors.certificateLightTextColor)
                            Text("University X")
                                .font(Theme.Fonts.custom(.regular, 8))
                                .foregroundStyle(Theme.Colors.certificateLightTextColor)
                        }
                    }
                    Spacer()
                }
                .padding(.trailing, 10)
                .padding(.leading, 10)
            }
        }
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
