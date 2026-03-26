//
//  ThreadView.swift
//  Discussion
//
//  Created by  Stepanok Ivan on 18.10.2022.
//

import SwiftUI
import Core
import Theme

public struct ThreadView: View {
    
    private var title: String
    public let thread: UserThread
    private var onBackTapped: (() -> Void) = {}
    
    @ObservedObject private var viewModel: ThreadViewModel
    @Environment(\.colorScheme) var colorScheme
    @State private var headingID = UUID()
    @State private var commentText: String = ""
    @State private var commentSize: CGFloat = .init(64)

    private enum Constants {
        static let scrollingDelay: TimeInterval = 0.5
    }

    public init(thread: UserThread,
                viewModel: ThreadViewModel) {
        self.thread = thread
        self.title = DiscussionLocalization.Thread.title
        self.viewModel = viewModel
    }
    
    public var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .top) {
                
                // MARK: - Page Body
                ScrollViewReader { scroll in
                    VStack {
                        ZStack(alignment: .top) {
                            RefreshableScrollViewCompat(action: {
                                _ = await viewModel.getThreadData(thread: thread, page: 1, refresh: true)
                            }) {
                                VStack {
                                    if let comments = viewModel.postComments {
                                        ParentCommentView(
                                            comments: comments,
                                            isThread: true,
                                            onAuthorTap: { username in
                                                viewModel.router.showUserDetails(username: username)
                                            },
                                            onLikeTap: {
                                                Task {
                                                    if await viewModel.vote(
                                                        id: comments.threadID,
                                                        isThread: true,
                                                        voted: comments.voted,
                                                        index: nil,
                                                        courseID: thread.courseID
                                                    ) {
                                                        viewModel.sendPostLikedState()
                                                    }
                                                }
                                            },
                                            onReportTap: {
                                                Task {
                                                    if await viewModel.flag(
                                                        id: comments.threadID,
                                                        isThread: true,
                                                        abuseFlagged: comments.abuseFlagged,
                                                        index: nil,
                                                        courseID: thread.courseID
                                                    ) {
                                                        viewModel.sendReportedState()
                                                    }
                                                }
                                            },
                                            onFollowTap: {
                                                Task {
                                                    if await viewModel.followThread(
                                                        following: comments.followed,
                                                        threadID: comments.threadID
                                                    ) {
                                                        viewModel.trackToggleFollowThread(
                                                            courseID: thread.courseID,
                                                            threadID: thread.id,
                                                            author: thread.author,
                                                            follow: viewModel.postComments?.followed ?? false
                                                        )
                                                        viewModel.sendPostFollowedState()
                                                    }
                                                }
                                            }
                                        )
                                        
                                        HStack {
                                            Text("\(viewModel.itemsCount)")
                                            Text(DiscussionLocalization.responsesCount(viewModel.itemsCount))
                                            Spacer()
                                        }
                                        .padding(.top, 20)
                                        .padding(.leading, 24)
                                        .font(Theme.Fonts.titleMedium)
                                        .foregroundColor(Theme.Colors.textPrimary)
                                        .id(headingID)

                                        ForEach(Array(comments.comments.enumerated()), id: \.offset) { index, comment in
                                            CommentCell(
                                                comment: comment,
                                                addCommentAvailable: true,
                                                shouldHighlight: viewModel.shouldHighlightResponse(index),
                                                onAuthorTap: { username in
                                                    viewModel.router.showUserDetails(username: username)
                                                },
                                                onLikeTap: {
                                                    Task {
                                                        await viewModel.vote(
                                                            id: comment.commentID,
                                                            isThread: false,
                                                            voted: comment.voted,
                                                            index: index,
                                                            courseID: thread.courseID
                                                        )
                                                    }
                                                },
                                                onReportTap: {
                                                    Task {
                                                        await viewModel.flag(
                                                            id: comment.commentID,
                                                            isThread: false,
                                                            abuseFlagged: comment.abuseFlagged,
                                                            index: index,
                                                            courseID: thread.courseID
                                                        )
                                                    }
                                                },
                                                onCommentsTap: {
                                                    viewModel.router.showComments(
                                                        courseID: thread.courseID,
                                                        commentID: comment.commentID,
                                                        parentComment: comment,
                                                        threadStateSubject: viewModel.threadStateSubject,
                                                        isBlackedOut: viewModel.isBlackedOut,
                                                        animated: true
                                                    )
                                                },
                                                onFetchMore: {
                                                    Task {
                                                        await viewModel.fetchMorePosts(thread: thread,
                                                                                       index: index)
                                                    }
                                                }
                                            )
                                            .id(index)
                                        }
                                        if viewModel.nextPage <= viewModel.totalPages {
                                            VStack(alignment: .center) {
                                                ProgressBar(size: 40, lineWidth: 8)
                                                    .padding(.top, 20)
                                            }
                                        }
                                        Spacer(minLength: 84)
                                    }
                                }
                                .onRightSwipeGesture {
                                    viewModel.router.back()
                                    onBackTapped()
                                    viewModel.sendUpdateUnreadState()
                                }
                                .frameLimit(width: proxy.size.width)
                            }
                            if !(thread.closed  || viewModel.isBlackedOut) {
                                FlexibleKeyboardInputView(
                                    hint: DiscussionLocalization.Thread.addResponse,
                                    sendText: { commentText in
                                        if let threadID = viewModel.postComments?.threadID {
                                            Task {
                                                await viewModel.postComment(
                                                    courseID: thread.courseID,
                                                    threadID: threadID,
                                                    rawBody: commentText,
                                                    parentID: viewModel.postComments?.parentID
                                                )
                                            }
                                        }
                                    }
                                )
                                .ignoresSafeArea(.all, edges: .horizontal)
                            }
                        }
                        .onReceive(viewModel.addPostSubject, perform: { newComment in
                            guard let newComment else { return }
                            viewModel.sendPostRepliesCountState()
                            viewModel.addNewPost(newComment)
                            withAnimation {
                                if viewModel.postComments?.comments.isEmpty == false {
                                    scroll.scrollTo(0, anchor: .bottom)
                                }
                            }
                        })
                        .onChange(of: viewModel.shouldScroll, perform: { shouldScroll in
                            guard shouldScroll else { return }

                            doAfter(Constants.scrollingDelay) {
                                withAnimation {
                                    scroll.scrollTo(headingID, anchor: .top)
                                }
                            }
                        })
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }.scrollAvoidKeyboard(dismissKeyboardByTap: true)
                }
                .padding(.top, 8)
                // MARK: - Error Alert
                if viewModel.showError {
                    VStack {
                        Spacer()
                        SnackBarView(message: viewModel.errorMessage)
                    }
                    .transition(.move(edge: .bottom))
                    .onAppear {
                        doAfter(Theme.Timeout.snackbarMessageLongTimeout) {
                            viewModel.errorMessage = nil
                        }
                    }
                }
                
                // MARK: - Alert
                if viewModel.showAlert {
                    VStack {
                        Text(viewModel.alertMessage ?? "")
                            .shadowCardStyle(
                                bgColor: Theme.Colors.accentColor,
                                textColor: Theme.Colors.primaryButtonTextColor
                            )
                            .padding(.top, 80)
                        Spacer()
                        
                    }
                    .transition(.move(edge: .top))
                    .onAppear {
                        doAfter(Theme.Timeout.snackbarMessageLongTimeout) {
                            viewModel.alertMessage = nil
                        }
                    }
                }
                if viewModel.fetchInProgress {
                    VStack(alignment: .center) {
                        ProgressBar(size: 40, lineWidth: 8)
                            .padding(.horizontal)
                            .accessibilityIdentifier("progress_bar")
                    }.frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .disabled(viewModel.fetchInProgress)
            .ignoresSafeArea(.all, edges: .horizontal)
            .hideNavigationBar(false)
            .navigationBarBackButtonHidden(true)
            .navigationTitle(title)
            .toolbar {
                ToolbarItem(
                    placement: .navigationBarLeading,
                    content: {
                        BackNavigationButton(
                            color: Theme.Colors.accentColor,
                            applyOffset: true
                        ) {
                            viewModel.router.back()
                        }
                    }
                )
            }
            .onFirstAppear {
                Task {
                    await viewModel.getThreadData(thread: thread, page: 1, onFirstAppear: true)
                }
                viewModel.trackDiscussionPostViewed(
                    courseID: thread.courseID,
                    topicID: thread.topicID,
                    threadID: thread.id
                )
            }
            .onDisappear {
                onBackTapped()
                viewModel.sendUpdateUnreadState()
            }
            .edgesIgnoringSafeArea(.bottom)
            .background(
                Theme.Colors.background
                    .ignoresSafeArea()
            )
        }
    }
}

#if DEBUG
struct CommentsView_Previews: PreviewProvider {
    static var previews: some View {
        let userThread = UserThread(id: "",
                                    author: "Peter Parker",
                                    authorLabel: "Peter",
                                    createdAt: Date(),
                                    updatedAt: Date(),
                                    rawBody: "Hello world!",
                                    renderedBody: "Hello world!",
                                    voted: false,
                                    voteCount: 3,
                                    courseID: "",
                                    topicID: "",
                                    type: .discussion,
                                    title: "Demo title",
                                    pinned: false,
                                    closed: false,
                                    following: true,
                                    commentCount: 23,
                                    avatar: "",
                                    unreadCommentCount: 4,
                                    abuseFlagged: true,
                                    hasEndorsed: true,
                                    numPages: 3)
        let vm = ThreadViewModel(interactor: DiscussionInteractor.mock,
                                 router: DiscussionRouterMock(),
                                 config: ConfigMock(),
                                 coreStorage: CoreStorageMock(),
                                 postStateSubject: .init(nil),
                                 responseID: nil,
                                 analytics: DiscussionAnalyticsMock())
        
        ThreadView(thread: userThread, viewModel: vm)
            .preferredColorScheme(.light)
            .previewDisplayName("ThreadView Light")
        
        ThreadView(thread: userThread, viewModel: vm)
            .preferredColorScheme(.dark)
            .previewDisplayName("ThreadView Dark")
        
    }
}
#endif
