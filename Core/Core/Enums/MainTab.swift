//
//  MainTab.swift
//  Core
//
//  Created by Vadim Kuznetsov on 12.06.24.
//

public enum MainTab {
    case discovery
    case dashboard
    case programs
    case profile
}

public enum Pacing: String { // NEEDS WORK - delete when moved to IAP Plugin
    case selfPace = "self"
    case instructor
}
