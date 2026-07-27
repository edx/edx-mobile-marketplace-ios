//
//  LocalNotfifcationManager.swift
//  Core
//
//  Created by Raviteja Gurram on 27/07/26.
//

import Foundation
import UserNotifications

public struct LocalNotificationManager {
    public static func send(title: String, body: String, delay: TimeInterval = 1) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let trigger: UNNotificationTrigger?
        if delay <= 0 {
            trigger = nil
        } else {
            trigger = UNTimeIntervalNotificationTrigger(timeInterval: max(1, delay), repeats: false)
        }
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error {
                debugPrint("[LocalNotificationManager] Failed to schedule notification: \(error.localizedDescription)")
            }
        }
    }
}
