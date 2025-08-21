//
//  ListDashboardViewModel.swift
//  Dashboard
//
//  Created by  Stepanok Ivan on 19.09.2022.
//

import Foundation
import Core
import SwiftUI
import Combine

public class ListDashboardViewModel: ObservableObject {
    
    public var nextPage = 1
    public var totalPages = 1
    @Published public private(set) var fetchInProgress = false
    @Published public private(set) var showLoader = false
    
    @Published var courses: [CourseItem] = []
    @Published var showError: Bool = false
    var errorMessage: String? {
        didSet {
            withAnimation {
                showError = errorMessage != nil
            }
        }
    }
    
    let connectivity: ConnectivityProtocol
    private let interactor: DashboardInteractorProtocol
    private let analytics: DashboardAnalytics
    private var cancellations: [AnyCancellable] = []
    private let upgradehandler: CourseUpgradeHandlerProtocol
    private let coreAnalytics: CoreAnalytics
    private var onCourseEnrolledCancellable: AnyCancellable?
    private var refreshEnrollmentsCancellable: AnyCancellable?
    let serverConfig: ServerConfigProtocol
    private var storage: CoreStorage
    
    public init(interactor: DashboardInteractorProtocol,
                connectivity: ConnectivityProtocol,
                analytics: DashboardAnalytics,
                upgradehandler: CourseUpgradeHandlerProtocol,
                coreAnalytics: CoreAnalytics,
                serverConfig: ServerConfigProtocol,
                storage: CoreStorage
    ) {
        self.interactor = interactor
        self.connectivity = connectivity
        self.analytics = analytics
        self.upgradehandler = upgradehandler
        self.coreAnalytics = coreAnalytics
        self.serverConfig = serverConfig
        self.storage = storage
        
        addObservers()
    }
    
    private func addObservers() {
        NotificationCenter.default
            .publisher(for: .onCourseEnrolled)
            .sink { [weak self] _ in
                guard let self else { return }
                Task {
                    await self.getMyCourses(page: 1, refresh: true)
                }
            }
            .store(in: &cancellations)

        NotificationCenter.default
            .publisher(for: .courseUpgradeCompletionNotification)
            .sink { [weak self] object in
                
                let showLoader = object.object as? Bool ?? false
                guard let self else { return }
                Task {
                    await self.getMyCourses(page: 1, refresh: true, showLoader: showLoader)
                }
            }
            .store(in: &cancellations)
        
        refreshEnrollmentsCancellable = NotificationCenter.default
            .publisher(for: .refreshEnrollments)
            .sink { [weak self] _ in
                guard let self = self else { return }
                Task {
                    await self.getMyCourses(page: 1, refresh: true)
                }
            }
    }
    
    @MainActor
    public func getMyCourses(
        page: Int,
        refresh: Bool = false,
        showLoader: Bool = false
    ) async {
        do {
            self.showLoader = showLoader
            fetchInProgress = true
            if connectivity.isInternetAvaliable {
                
                if refresh {
                    courses = try await interactor.getEnrollments(page: page)
                    self.totalPages = 1
                    self.nextPage = 2
                } else {
                    courses += try await interactor.getEnrollments(page: page)
                    self.nextPage += 1
                }
                if !courses.isEmpty {
                    totalPages = courses[0].numPages
                }
                fetchInProgress = false
                self.showLoader = false
            } else {
                courses = try await interactor.getEnrollmentsOffline()
                self.nextPage += 1
                fetchInProgress = false
                self.showLoader = false
            }
        } catch let error {
            fetchInProgress = false
            self.showLoader = false
            if error is NoCachedDataError {
                errorMessage = CoreLocalization.Error.noCachedData
            } else {
                errorMessage = CoreLocalization.Error.unknownError
            }
        }
    }
    
    @MainActor
    public func getMyCoursesPagination(index: Int) async {
        if !fetchInProgress {
            if totalPages > 1 {
                if index == courses.count - 3 {
                    if totalPages != 1 {
                        if nextPage <= totalPages {
                            await getMyCourses(page: self.nextPage)
                        }
                    }
                }
            }
        }
    }
    
    func trackDashboardCourseClicked(courseID: String, courseName: String) {
        analytics.dashboardCourseClicked(courseID: courseID, courseName: courseName)
    }
}

// Course upgrade
extension ListDashboardViewModel {
    func resolveUnfinishedPayment() async {
        await upgradehandler.resolveUnfinishedPayments(
            loggedInUserID: storage.user?.id ?? .zero,
            coreAnalytics: coreAnalytics
        )
    }
}
