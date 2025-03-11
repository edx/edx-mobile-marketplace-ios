//
//  AuthorizationAnalytics.swift
//  Authorization
//
//  Created by  Stepanok Ivan on 27.06.2023.
//

import Foundation
import Core
import OEXFoundation

public enum AuthMethod: Equatable {
    case password
    case SSO
    case socialAuth(SocialAuthMethod)

    public var analyticsValue: String {
        switch self {
        case .password:
            "password"
        case .SSO:
            "SSO"
        case .socialAuth(let socialAuthMethod):
            socialAuthMethod.rawValue
        }
    }
}

public enum SocialAuthMethod: String, Sendable {
    case facebook
    case google
    case microsoft
    case apple
}

//sourcery: AutoMockable
public protocol AuthorizationAnalytics {
    func identify(id: String, username: String, email: String)
    func userLogin(method: AuthMethod)
    func registerClicked()
    func signInClicked()
    func userSignInClicked(method: String)
    func socialRegisterClicked(method: String)
    func createAccountClicked(method: String)
    func socialAuthSuccess(method: String)
    func registrationSuccess(method: String)
    func socialAuthFailure(method: String, errorCode: String?, errorMessage: String?)
    func validationFailure(method: String, statusCode: Int?, errorMessage: String?)
    func registerFailure(method: String, errorCode: String?, errorMessage: String?)
    func signInFailure(method: String, errorCode: String?, errorMessage: String?)
    func forgotPasswordClicked()
    func resetPasswordClicked()
    func resetPassword(success: Bool)
    func authTrackScreenEvent(_ event: AnalyticsEvent, biValue: EventBIValue)
}

#if DEBUG
class AuthorizationAnalyticsMock: AuthorizationAnalytics {
    func identify(id: String, username: String, email: String) {}
    public func userLogin(method: AuthMethod) {}
    public func registerClicked() {}
    public func signInClicked() {}
    public func userSignInClicked(method: String) {}
    public func socialRegisterClicked(method: String) {}
    public func createAccountClicked(method: String) {}
    public func socialAuthSuccess(method: String) {}
    public func registrationSuccess(method: String) {}
    public func socialAuthFailure(method: String, errorCode: String?, errorMessage: String?) {}
    public func validationFailure(method: String, statusCode: Int?, errorMessage: String?) {}
    public func registerFailure(method: String, errorCode: String?, errorMessage: String?) {}
    public func signInFailure(method: String, errorCode: String?, errorMessage: String?) {}
    public func forgotPasswordClicked() {}
    public func resetPasswordClicked() {}
    public func resetPassword(success: Bool) {}
    public func authTrackScreenEvent(_ event: AnalyticsEvent, biValue: EventBIValue) {}
}
#endif
