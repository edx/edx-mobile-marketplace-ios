//
//  Untitled.swift
//  Notifications
//
//  Created by Shafqat Muneer on 3/5/25.
//

import Foundation

public protocol NotificationsDeepLinkManager {
    func showDiscussions(_ notification: SingleNotification) async
}

// Mark - For testing and SwiftUI preview
#if DEBUG
public class NotificationsDeepLinkManagerMock: NotificationsDeepLinkManager {
    public func showDiscussions(_ notification: SingleNotification) async {}
}
#endif
