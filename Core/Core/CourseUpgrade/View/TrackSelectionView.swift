//
//  TrackSelectionView.swift
//  Core
//
//  Created by Muhammad Tayyab Akram on 5/2/25.
//

import SwiftUI
import Theme

public struct TrackSelectionView: View {
    @Environment(\.isHorizontal) private var isHorizontal
    @ObservedObject private var viewModel: TrackSelectionViewModel

    public init(viewModel: TrackSelectionViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        NavigationView {
            VStack {
                scrollView
                    .padding(.horizontal, 24)
                    .padding(.top, 24)

                Spacer(minLength: 16)

                ZStack {
                    let buttonTitle = viewModel.continueTitle ?? ""
                    let canShowButton = !viewModel.isLoading && !buttonTitle.isEmpty

                    StyledButton(
                        buttonTitle,
                        action: {
                            Task {
                                await viewModel.proceed()
                            }
                        },
                        color: Theme.Colors.accentButtonColor,
                        textColor: Theme.Colors.styledButtonText,
                        isTitleTracking: false,
                        isLimitedOnPad: false
                    )
                    .opacity(canShowButton ? 1 : 0)
                    .disabled(!canShowButton)

                    ProgressBar(size: 30, lineWidth: 8)
                        .opacity(canShowButton ? 0 : 1)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
            .background {
                Theme.Colors.background
                    .ignoresSafeArea()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if !viewModel.interactiveDismissDisabled {
                            viewModel.dismiss()
                        }
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(Theme.Colors.accentColor)
                    }
                    .accessibilityIdentifier("close_button")
                }
            }
        }
        .navigationViewStyle(.stack)
        .interactiveDismissDisabled(viewModel.interactiveDismissDisabled)
        .task {
            await viewModel.fetchProduct()
        }
        .onFirstAppear {
            viewModel.trackScreenViewed()
        }
    }

    @ViewBuilder
    private var scrollView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Titles
                VStack(alignment: .leading, spacing: 16) {
                    Text("\(CoreLocalization.CourseUpgrade.View.title) \(viewModel.productName)")
                        .font(Theme.Fonts.titleLarge)
                        .lineLimit(3)
                        .truncationMode(.tail)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text(CoreLocalization.TrackSelection.View.title)
                        .font(Theme.Fonts.titleLarge)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .foregroundColor(Theme.Colors.textPrimary)

                // Cards
                adaptiveStack(
                    spacing: 8,
                    isHorizontal: isHorizontal
                ) {
                    ForEach(viewModel.cards, id: \.key) { card in
                        let key = card.key
                        let info = card.value

                        Button(
                            action: {
                                viewModel.cardPressed(key)
                            },
                            label: {
                                TrackCardView(
                                    heading: info.heading,
                                    subheading: info.subheading,
                                    paragraphs: info.paragraphs,
                                    isSelected: viewModel.selectedCard == key
                                )
                            }
                        )
                    }
                }
                .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

#if DEBUG
#Preview {
    TrackSelectionView(
        viewModel: TrackSelectionViewModel(
            courseID: "",
            productName: "Preview",
            sku: "SKU",
            pacing: "self",
            lmsPrice: .zero,
            accessExpires: Date(),
            handler: CourseUpgradeHandlerProtocolMock(),
            analytics: CoreAnalyticsMock(),
            certificatePreviewExperimentManager: CertificatePreviewManagingMock(),
            router: BaseRouterMock()
        )
    )
}
#endif
