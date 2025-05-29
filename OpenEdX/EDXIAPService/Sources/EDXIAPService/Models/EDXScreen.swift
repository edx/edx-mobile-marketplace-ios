//
//  EDXScreen.swift
//  EDXIAPService
//
//  Created by Vadim Kuznetsov on 29.05.25.
//

public enum EDXScreen: String, Sendable {
    case dashboard
    case courseDashboard = "course_dashboard"
    case courseComponent = "course_component"
    case unknown
}
