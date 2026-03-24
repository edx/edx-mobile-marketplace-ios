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

public protocol TrackingConsentManaging {
    func setTrackingConsent(granted: Bool)
}

#if DEBUG
public struct UserSessionManagingMock: UserSessionManaging {
    public init() {}
    public func identifyUser(id: String) {}
    public func resetUser() {}
}

public struct TrackingConsentManagingMock: TrackingConsentManaging {
    public init() {}
    public func setTrackingConsent(granted: Bool) {}
}
#endif
