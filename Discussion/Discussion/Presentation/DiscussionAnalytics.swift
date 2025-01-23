//
//  DiscussionAnalytics.swift
//  Discussion
//
//  Created by  Stepanok Ivan on 29.06.2023.
//

import Foundation

//sourcery: AutoMockable
public protocol DiscussionAnalytics {
    func discussionAllPostsClicked(courseId: String)
    func discussionFollowingClicked(courseId: String)
    func discussionTopicClicked(courseId: String, topicId: String)
    
    func discussionCreateNewPost(
        courseID: String,
        topicID: String,
        postType: String,
        followPost: Bool,
        author: String
    )
    
    func discussionResponseAdded(
        courseID: String,
        threadID: String,
        responseID: String,
        author: String
    )
    
    func discussionCommentAdded(
        courseID: String,
        threadID: String,
        responseID: String,
        commentID: String,
        author: String
    )
    
    func discussionFollowToggle(
        courseID: String,
        threadID: String,
        author: String,
        follow: Bool
    )
    
    func discussionLikeToggle(
        courseID: String,
        threadID: String,
        responseID: String?,
        commentID: String?,
        author: String,
        discussionType: String,
        like: Bool
    )
    
    func discussionReportToggle(
        courseID: String,
        threadID: String,
        responseID: String?,
        commentID: String?,
        author: String,
        discussionType: String,
        report: Bool
    )
    
    func discussionTopicViewed(
        courseID: String,
        topicID: String
    )
    
    func discussionPostViewed(
        courseID: String,
        topicID: String,
        threadID: String
    )
    
    func discussionResponseViewed(
        courseID: String,
        threadID: String,
        responseID: String
    )
}

#if DEBUG
class DiscussionAnalyticsMock: DiscussionAnalytics {
    public func discussionAllPostsClicked(courseId: String) {}
    public func discussionFollowingClicked(courseId: String) {}
    public func discussionTopicClicked(courseId: String, topicId: String) {}
    
    public func discussionCreateNewPost(
        courseID: String,
        topicID: String,
        postType: String,
        followPost: Bool,
        author: String
    ) {}
    
    public func discussionResponseAdded(
        courseID: String,
        threadID: String,
        responseID: String,
        author: String
    ) {}
    
    public func discussionCommentAdded(
        courseID: String,
        threadID: String,
        responseID: String,
        commentID: String,
        author: String
    ) {}
    
    public func discussionFollowToggle(
        courseID: String,
        threadID: String,
        author: String,
        follow: Bool
    ) {}
    
    public func discussionLikeToggle(
        courseID: String,
        threadID: String,
        responseID: String? = nil,
        commentID: String? = nil,
        author: String,
        discussionType: String,
        like: Bool
    ) {}
    
    public func discussionReportToggle(
        courseID: String,
        threadID: String,
        responseID: String? = nil,
        commentID: String? = nil,
        author: String,
        discussionType: String,
        report: Bool
    ) {}
    
    func discussionTopicViewed(
        courseID: String,
        topicID: String
    ) {}
    
    func discussionPostViewed(
        courseID: String,
        topicID: String,
        threadID: String
    ) {}
    
    func discussionResponseViewed(
        courseID: String,
        threadID: String,
        responseID: String
    ) {}
}
#endif
