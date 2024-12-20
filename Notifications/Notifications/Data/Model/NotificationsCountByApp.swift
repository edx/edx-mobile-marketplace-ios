//
//  NotificationsCountByApp.swift
//  Notifications
//
//  Created by Saeed Bashir on 12/17/24.
//


public struct NotificationsCountByApp {
    public var discussion: Int
    public var updates: Int
    public var grading: Int
    
    public init(discussion: Int, updates: Int, grading: Int) {
        self.discussion = discussion
        self.updates = updates
        self.grading = grading
    }
}
