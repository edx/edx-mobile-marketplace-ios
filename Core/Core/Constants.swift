//
//  Constants.swift
//  Core
//
//  Created by Vladimir Chekyrta on 14.09.2022.
//

import Foundation

// TODO move it to config file and parse
public struct Constants {
    public static let GrantTypePassword = "password"
    public static let GrantTypeRefreshToken = "refresh_token"
}

public struct IAPPriceRange {
    public static let minimum = 1.0
    public static let maximum = 1000.0
}
