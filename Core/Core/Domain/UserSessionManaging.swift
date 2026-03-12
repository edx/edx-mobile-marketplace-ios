//
//  UserSessionManaging.swift
//  Core
//
//  Created by Sumanta Roy on 12/03/26.

import Foundation

public protocol UserSessionManaging {
    func identifyUser(id: String)
    func resetUser()
}

#if DEBUG
public struct UserSessionManagingMock: UserSessionManaging {
    public init() {}
    public func identifyUser(id: String) {}
    public func resetUser() {}
}
#endif
