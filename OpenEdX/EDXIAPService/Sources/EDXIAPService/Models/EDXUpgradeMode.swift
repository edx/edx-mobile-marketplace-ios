//
//  EDXUpgradeMode.swift
//  EDXIAPService
//
//  Created by Vadim Kuznetsov on 29.05.25.
//

public enum EDXUpgradeMode: String, Sendable {
    case silent
    case userInitiated = "user_initiated"
    case restore
}
