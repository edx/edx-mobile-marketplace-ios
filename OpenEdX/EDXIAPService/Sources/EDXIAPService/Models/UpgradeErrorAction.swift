//
//  UpgradeErrorAction.swift
//  EDXIAPService
//
//  Created by Vadim Kuznetsov on 30.05.25.
//

public enum UpgradeErrorAction: String {
    case refreshToRetry = "refresh"
    case reloadPrice = "reload_price"
    case emailSupport = "get_help"
    case close
}
