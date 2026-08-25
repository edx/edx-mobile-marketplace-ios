//
//  CourseContentView.swift
//  Course
//
//  Created by  Stepanok Ivan on 24.06.2025.
//

import SwiftUI
import Core
import Kingfisher
import Theme
import SwiftUIIntrospect

public struct CourseContentView: View {
    
    @StateObject private var viewModel: CourseContainerViewModel
    private let title: String
    private let courseID: String
    private let isVideo: Bool
    @State private var openCertificateView: Bool = false
    
    private var videoContentData: VideoContentData {
        VideoContentData(
            courseVideosStructure: viewModel.courseVideosStructure,
            courseProgress: viewModel.courseVideosStructure?.courseProgress,
            sequentialsDownloadState: viewModel.sequentialsDownloadState,
            isShowProgress: viewModel.isShowProgress,
            showError: viewModel.showError,
            errorMessage: viewModel.errorMessage
        )
    }
    
    private var assignmentContentData: AssignmentContentData {
        AssignmentContentData(
            courseAssignmentsStructure: viewModel.courseAssignmentsStructure,
            assignmentSections: viewModel.assignmentSectionsData.map { section in
                AssignmentSectionUI(
                    key: section.label,
                    subsections: section.subsections,
                    weight: section.weight
                )
            },
            assignmentTypeColors: Dictionary(uniqueKeysWithValues:
                viewModel.assignmentSectionsData.map { section in
                    (section.label, viewModel.assignmentTypeColor(for: section.label) ?? "#666666")
                }
            ),
            isShowProgress: viewModel.isShowProgress,
            showError: viewModel.showError,
            errorMessage: viewModel.errorMessage
        )
    }

    @Binding private var selection: Int
    @Binding private var coordinate: CGFloat
    @Binding private var collapsed: Bool
    @Binding private var viewHeight: CGFloat
    @Binding private var shouldShowUpgradeButton: Bool
    @Binding private var shouldHideMenuBar: Bool
    
    private var idiom: UIUserInterfaceIdiom { UIDevice.current.userInterfaceIdiom }
    
    public init(
        viewModel: CourseContainerViewModel,
        title: String,
        courseID: String,
        isVideo: Bool,
        selection: Binding<Int>,
        coordinate: Binding<CGFloat>,
        collapsed: Binding<Bool>,
        viewHeight: Binding<CGFloat>,
        shouldShowUpgradeButton: Binding<Bool>,
        shouldHideMenuBar: Binding<Bool>
    ) {
        self.title = title
        self._viewModel = StateObject(wrappedValue: { viewModel }())
        self.courseID = courseID
        self.isVideo = isVideo
        self._selection = selection
        self._coordinate = coordinate
        self._collapsed = collapsed
        self._viewHeight = viewHeight
        self._shouldShowUpgradeButton = shouldShowUpgradeButton
        self._shouldHideMenuBar = shouldHideMenuBar
    }
    
    public var body: some View {
        ZStack(alignment: .top) {
            GeometryReader { proxy in
                VStack(alignment: .center) {
                    ScrollView {
                        VStack(spacing: 0) {
                            DynamicOffsetView(
                                coordinate: $coordinate,
                                collapsed: $collapsed,
                                viewHeight: $viewHeight,
                                shouldShowUpgradeButton: $shouldShowUpgradeButton,
                                shouldHideMenuBar: $shouldHideMenuBar
                            )
                            RefreshProgressView(isShowRefresh: $viewModel.isShowRefresh)
                            VStack(alignment: .leading) {
                                // MARK: - Segmented Control
                                ContentSegmentedControl(
                                    selectedTab: $viewModel.selectedTab,
                                    courseId: courseID,
                                    courseName: title,
                                    analytics: viewModel.analytics
                                )
                                    .padding(.horizontal, 24)
                                    .padding(.top, 16)

                                certificateView
                                
                                // MARK: - Content based on selected tab
                                contentForSelectedTab(proxy: proxy)
                            }
                            .frameLimit(width: proxy.size.width)
                        }
                    }
                    .refreshable {
                        Task {
                            await viewModel.getCourseBlocks(courseID: courseID, withProgress: false)
                        }
                    }
                    .onRightSwipeGesture {
                        viewModel.router.back()
                    }
                }
                .accessibilityAction {}
                
                // MARK: Review Course Grading Policy
                if viewModel.selectedTab == .assignments {
                    VStack(spacing: 18) {
                        Divider()
                        Button(action: {
                            viewModel.selection = 2
                        }, label: {
                        HStack(spacing: 4) {
                            CoreAssets.gallery.swiftUIImage.renderingMode(.template)
                            Text(CourseLocalization.Assignment.reviewGradingPolicy)
                                .font(Theme.Fonts.labelLarge)
                        }
                        .foregroundStyle(Theme.Colors.accentColor)
                        })
                    }
                    .background(Theme.Colors.background)
                    .frame(maxHeight: .infinity, alignment: .bottom)
                }
                
                // MARK: - Offline mode SnackBar
                OfflineSnackBarView(
                    connectivity: viewModel.connectivity,
                    reloadAction: {
                        await withTaskGroup(of: Void.self) { group in
                            group.addTask {
                                await viewModel.getCourseBlocks(courseID: courseID, withProgress: false)
                            }
                            group.addTask {
                                await viewModel.getCourseDeadlineInfo(courseID: courseID, withProgress: false)
                            }
                        }
                    }
                )
                
                // MARK: - Error Alert
                if viewModel.showError {
                    VStack {
                        Spacer()
                        SnackBarView(message: viewModel.errorMessage)
                    }
                    .padding(.bottom, viewModel.isInternetAvaliable
                             ? 0 : OfflineSnackBarView.height)
                    .transition(.move(edge: .bottom))
                    .onAppear {
                        doAfter(Theme.Timeout.snackbarMessageLongTimeout) {
                            viewModel.errorMessage = nil
                        }
                    }
                }
            }
        }
        .onAppear {
            Task {
                await viewModel.updateCourseIfNeeded(courseID: courseID)
            }
        }
        .background(
            Theme.Colors.background
                .ignoresSafeArea()
        )
    }

    @ViewBuilder
    private var certificateView: some View {
        if let certificate = viewModel.courseStructure?.certificate,
           let url = certificate.url,
           url.count > 0 {
            MessageSectionView(
                title: CourseLocalization.Outline.passedTheCourse(title),
                actionTitle: CourseLocalization.Outline.viewCertificate,
                action: {
                    openCertificateView = true
                    viewModel.trackViewCertificateClicked(courseID: courseID)
                }
            )
            .padding(.horizontal, 24)
            .padding(.top, 16)
            .fullScreenCover(
                isPresented: $openCertificateView,
                content: {
                    WebBrowser(
                        url: url,
                        pageTitle: CourseLocalization.Outline.certificate
                    )
                }
            )
        }
    }
    
    @ViewBuilder
    private func contentForSelectedTab(proxy: GeometryProxy) -> some View {
        switch viewModel.selectedTab {
        case .all:
            AllContentView(
                viewModel: viewModel,
                proxy: proxy,
                title: title,
                courseID: courseID,
                dateTabIndex: CourseTab.dates.rawValue,
                isVideo: isVideo
            )
        case .videos:
            VideosContentView(
                videoContentData: videoContentData,
                proxy: proxy,
                onVideoTap: { video, chapter in
                    viewModel.handleVideoTap(video: video, chapter: chapter)
                },
                onDownloadSectionTap: { chapter, state in
                    await viewModel.onDownloadViewTap(chapter: chapter, state: state)
                },
                onTabSelection: { tabId in
                    viewModel.selection = tabId
                },
                onErrorDismiss: {
                    viewModel.errorMessage = nil
                },
                onShowCompletedAnalytics: {
                    viewModel.trackShowCompletedSubsectionClicked()
                }
            )
            .onReceive(NotificationCenter.default.publisher(for: .onBlockCompletion)) { _ in
                Task {
                    await viewModel.getCourseBlocks(courseID: courseID, withProgress: false)
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .onVideoProgressUpdated)) { notification in
                guard let userInfo = notification.userInfo,
                      let blockID = userInfo["blockID"] as? String,
                      let progress = userInfo["progress"] as? Double else {
                    return
                }
                Task {
                    await viewModel.updateVideoProgress(blockID: blockID, progress: progress)
                }
            }
        case .assignments:
            AssignmentsContentView(
                assignmentContentData: assignmentContentData,
                proxy: proxy,
                onAssignmentTap: { subsectionUI in
                    viewModel.navigateToAssignment(for: subsectionUI.subsection)
                },
                onTabSelection: { tabId in
                    viewModel.selection = tabId
                },
                onErrorDismiss: {
                    viewModel.errorMessage = nil
                },
                onShowCompletedAnalytics: {
                    viewModel.trackShowCompletedSubsectionClicked()
                }
            )
            .onReceive(NotificationCenter.default.publisher(for: .onBlockCompletion)) { _ in
                viewModel.updateCourseProgress = true
                Task {
                    await viewModel.getCourseBlocks(courseID: courseID, withProgress: false)
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .onblockCompletionRequested)) { _ in
                Task {
                    await viewModel.getCourseBlocks(courseID: courseID, withProgress: false)
                }
            }
            .task {
                await viewModel.updateCourseIfNeeded(courseID: courseID)
            }
        }
    }
}

#if DEBUG
#Preview {
    let viewModel = CourseContainerViewModel(
        interactor: CourseInteractor.mock,
        authInteractor: AuthInteractor.mock,
        enrollmentInteractor: EnrollmentInteractor.mock,
        router: CourseRouterMock(),
        analytics: CourseAnalyticsMock(),
        config: ConfigMock(),
        connectivity: Connectivity(),
        manager: DownloadManagerMock(),
        storage: CourseStorageMock(),
        isActive: true,
        courseStart: Date(),
        courseEnd: nil,
        enrollmentStart: Date(),
        enrollmentEnd: nil,
        lastVisitedBlockID: nil,
        coreAnalytics: CoreAnalyticsMock(),
        serverConfig: ServerConfigProtocolMock(),
        courseHelper: CourseDownloadHelper(courseStructure: nil, manager: DownloadManagerMock())
    )
    
    CourseContentView(
        viewModel: viewModel,
        title: "Course title",
        courseID: "",
        isVideo: false,
        selection: .constant(0),
        coordinate: .constant(0),
        collapsed: .constant(false),
        viewHeight: .constant(0),
        shouldShowUpgradeButton: .constant(true),
        shouldHideMenuBar: .constant(false)
    )
}
#endif
