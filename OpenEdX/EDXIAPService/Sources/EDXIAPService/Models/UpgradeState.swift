//
//  UpgradeState.swift
//  EDXIAPService
//
//  Created by Vadim Kuznetsov on 29.05.25.
//

enum UpgradeState: Sendable {
    case initial
    case basket
    case checkout
    case payment
    case verify
    case complete
    case error(UpgradeError)
}
