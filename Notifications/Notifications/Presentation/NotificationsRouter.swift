//
//  NotificationsRouter.swift
//  Notifications
//
//  Created by Saeed Bashir on 11.12.2024.
//

import Foundation
import Core
import Discussion
import Discovery

public protocol NotificationsRouter: BaseRouter {
    func showPushSettings()
    
    func showProgress()
    
    func dismissProgress()
    
    func showThreads(
        topicID: String,
        courseDetails: CourseDetails,
        topics: Topics,
        isBlackedOut: Bool
    )
    
    func showThread(
        userThread: UserThread,
        isBlackedOut: Bool,
        responseID: String?
    )
    
    func showComment(
        courseID: String,
        comment: UserComment,
        parentComment: Post,
        isBlackedOut: Bool
    )
}

// Mark - For testing and SwiftUI preview
#if DEBUG
public class NotificationsRouterMock: BaseRouterMock, NotificationsRouter {
    public override init() {}
    
    public func showPushSettings() {}
    
    public func showProgress() {}
    
    public func dismissProgress() {}
    
    public func showThreads(
        topicID: String,
        courseDetails: CourseDetails,
        topics: Topics,
        isBlackedOut: Bool
    ) {}
    
    public func showThread(
        userThread: UserThread,
        isBlackedOut: Bool,
        responseID: String?
    ) {}
    
    public func showComment(
        courseID: String,
        comment: UserComment,
        parentComment: Post,
        isBlackedOut: Bool
    ) {}
}
#endif
