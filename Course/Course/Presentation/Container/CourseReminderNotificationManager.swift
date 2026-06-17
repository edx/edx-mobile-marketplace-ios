//
//  CourseReminderNotificationManager.swift
//  Course
//
//  DEMO: Local notification for course completion reminder
//  Remove this entire file after demo
//

import Foundation
import UserNotifications

public final class CourseReminderNotificationManager {
    
    public static let shared = CourseReminderNotificationManager()
    public static let identifierPrefix = "course_completion_reminder_"
    
    private let triggerInterval: TimeInterval = 30 // 5 minutes
    
    private init() {}
    
    /// Schedule a reminder notification when user leaves course dashboard
    public func scheduleReminder(
        courseID: String,
        courseTitle: String,
        org: String?,
        completionPercentage: Int
    ) {
        // Always cancel existing one first
        cancelReminder(for: courseID)
        
        let content = UNMutableNotificationContent()
        content.title = "Continue Learning"
        content.body = "You've completed \(completionPercentage)% of \"\(courseTitle)\". Keep up the momentum!"
        content.sound = .default
        
        // Format userInfo to match existing DeepLink structure
        // Keys match Payload keys used by DeepLink init
        content.userInfo = [
            "course_id": courseID,
            "screen_name": "course_dashboard",
            "course_title": courseTitle,
            "org": org ?? "",
            "completion_percentage": completionPercentage,
            "is_local_course_reminder": true
        ]
        
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: triggerInterval,
            repeats: false
        )
        
        let identifier = Self.identifierPrefix + courseID
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                debugPrint("[CourseReminder] Schedule failed: \(error.localizedDescription)")
            } else {
                debugPrint("[CourseReminder] Scheduled: \(courseTitle) (\(completionPercentage)%) - fires in 5 min")
            }
        }
    }
    
    /// Cancel pending reminder for a specific course
    public func cancelReminder(for courseID: String) {
        let identifier = Self.identifierPrefix + courseID
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [identifier]
        )
        debugPrint("[CourseReminder] Cancelled for course: \(courseID)")
    }
    
    /// Request notification permission if needed
    public func requestPermissionIfNeeded() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            if settings.authorizationStatus == .notDetermined {
                UNUserNotificationCenter.current().requestAuthorization(
                    options: [.alert, .sound]
                ) { granted, _ in
                    debugPrint("[CourseReminder] Permission granted: \(granted)")
                }
            }
        }
    }
    
    /// Check if a notification response is from our local reminder
    public static func isLocalCourseReminder(_ userInfo: [AnyHashable: Any]) -> Bool {
        return userInfo["is_local_course_reminder"] as? Bool == true
    }
}
