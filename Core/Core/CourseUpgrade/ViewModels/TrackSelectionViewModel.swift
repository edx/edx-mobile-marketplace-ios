//
//  TrackSelectionViewModel.swift
//  Core
//
//  Created by Muhammad Tayyab Akram on 5/5/25.
//

import Foundation
import Combine

public final class TrackSelectionViewModel: ObservableObject {
    typealias Cards = KeyValuePairs<TrackCardKey, TrackCardInfo>

    @Published private(set) var cards: Cards = [:]
    @Published private(set) var selectedCard: TrackCardKey?
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var interactiveDismissDisabled = false

    private(set) var continueTitle: String?

    private let accessExpires: Date
    private let analytics: CoreAnalytics
    private let router: BaseRouter
    private let upgradeViewModel: UpgradeInfoViewModel
    private var cancellables = Set<AnyCancellable>()

    var productName: String { upgradeViewModel.productName }

    public init(
        courseID: String,
        productName: String,
        sku: String,
        pacing: String,
        lmsPrice: Double,
        accessExpires: Date,
        handler: CourseUpgradeHandlerProtocol,
        analytics: CoreAnalytics,
        certificatePreviewExperimentManager: CertificatePreviewManaging,
        router: BaseRouter
    ) {
        self.accessExpires = accessExpires
        self.analytics = analytics
        self.router = router
        self.upgradeViewModel = UpgradeInfoViewModel(
            productName: productName,
            message: "",
            sku: sku,
            courseID: courseID,
            screen: .trackSelection,
            handler: handler,
            pacing: pacing,
            analytics: analytics,
            certificatePreviewExperimentManager: certificatePreviewExperimentManager,
            router: router,
            lmsPrice: lmsPrice
        )

        upgradeViewModel.$isLoading
            .sink { [weak self] isLoading in
                guard let self else { return }

                Task { @MainActor in
                    self.isLoading = isLoading
                    self.updateCards()
                    self.refreshContinueTitle()
                }
            }
            .store(in: &cancellables)

        upgradeViewModel.$interactiveDismissDisabled
            .assign(to: &$interactiveDismissDisabled)

        upgradeViewModel.$error
            .sink { [weak self] error in
                guard let self else { return }

                if error != nil {
                    Task {
                        await self.dismiss()
                    }
                }
            }
            .store(in: &cancellables)

        NotificationCenter.default
            .publisher(for: .courseUpgradeCompletionNotification)
            .sink { [weak self] _ in
                guard let self else { return }

                Task {
                    await self.dismiss()
                }
            }
            .store(in: &cancellables)

        selectCard(.certificate)
    }

    func cardPressed(_ key: TrackCardKey) {
        selectCard(key)
    }

    func fetchProduct() async {
        await upgradeViewModel.fetchProduct()
    }

    @MainActor
    func proceed() async {
        switch selectedCard {
        case .certificate:
            await upgradeViewModel.purchase()
        case .free:
            trackContinueWithFreeTrackClicked()
            dismiss()
        case .none: break
        }
    }

    @MainActor
    func dismiss() {
        router.dismiss()
    }

    private func updateCards() {
        let expiresAt = accessExpires.dateToString(style: .monthDay)

        cards = [
            .certificate: TrackCardInfo(
                heading: (
                    upgradeViewModel.price.isEmpty
                        ? CoreLocalization.TrackSelection.Card.earnCertificateHeading
                        : CoreLocalization.TrackSelection.Card
                            .earnCertificateWithPriceHeading(upgradeViewModel.price)
                ),
                subheading: "",
                description: CoreLocalization.TrackSelection.Card.earnCertificateDescription
            ),
            .free: TrackCardInfo(
                heading: CoreLocalization.TrackSelection.Card.accessCourseHeading,
                subheading: CoreLocalization.TrackSelection.Card
                    .accessCourseSubheading(expiresAt),
                description: CoreLocalization.TrackSelection.Card
                    .accessCourseDescription(expiresAt)
            )
        ]
    }

    private func selectCard(_ key: TrackCardKey) {
        selectedCard = key
        refreshContinueTitle()
    }

    private func refreshContinueTitle() {
        switch selectedCard {
        case .certificate:
            if upgradeViewModel.price.isEmpty {
                continueTitle = nil
            } else {
                continueTitle = CoreLocalization.TrackSelection.Button
                    .continueToPayment(upgradeViewModel.price)
            }
        case .free:
            continueTitle = CoreLocalization.TrackSelection.Button.continueWithFreeTrack
        case .none:
            continueTitle = nil
        }
    }

    func trackScreenViewed() {
        analytics.trackSelectionViewed(
            courseID: upgradeViewModel.courseID,
            pacing: upgradeViewModel.pacing,
            lmsPrice: upgradeViewModel.lmsPrice
        )
    }

    func trackContinueWithFreeTrackClicked() {
        analytics.trackContinueWithFreeTrackClicked(
            courseID: upgradeViewModel.courseID,
            pacing: upgradeViewModel.pacing,
            lmsPrice: upgradeViewModel.lmsPrice
        )
    }
}

enum TrackCardKey {
    case certificate
    case free
}
