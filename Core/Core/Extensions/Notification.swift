//
//  Notification.swift
//  Core
//
//  Created by Vladimir Chekyrta on 15.12.2022.
//

import Foundation
import UserNotifications

public extension Notification.Name {
    static let userAuthorized = Notification.Name("userAuthorized")
    static let userLoggedOut = Notification.Name("userLoggedOut")
    static let onCourseEnrolled = Notification.Name("onCourseEnrolled")
    static let onblockCompletionRequested = Notification.Name("onblockCompletionRequested")
    static let onTokenRefreshFailed = Notification.Name("onTokenRefreshFailed")
    static let onActualVersionReceived = Notification.Name("onActualVersionReceived")
    static let onAppUpgradeAccountSettingsTapped = Notification.Name("onAppUpgradeAccountSettingsTapped")
    static let onNewVersionAvaliable = Notification.Name("onNewVersionAvaliable")
    static let webviewReloadNotification = Notification.Name("webviewReloadNotification")
    static let onBlockCompletion = Notification.Name("onBlockCompletion")
    static let shiftCourseDates = Notification.Name("shiftCourseDates")
    static let profileUpdated = Notification.Name("profileUpdated")
    static let unfullfilledTransctionsNotification = Notification.Name("unfullfilledTransctionsNotification")
    static let courseUpgradeCompletionNotification = Notification.Name("CourseUpgradeCompletionNotification")
    static let courseUpgradeUILoadingShouldEnd = Notification.Name("courseUpgradeUILoadingShouldEnd")
    static let getCourseDates = Notification.Name("getCourseDates")
    static let refreshEnrollments = Notification.Name("refreshEnrollments")
    static let notificationRegistration = Notification.Name("notificationRegistration")
}

public extension Notification {
    enum UserInfoKey: String {
        case isForced
        case status
    }
}

public struct LocalNotificationManager {
    public static func send(title: String, body: String, delay: TimeInterval = 1) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: delay, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
}
