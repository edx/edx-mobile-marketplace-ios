//
//  SocialAuthViewModel.swift
//  Authorization
//
//  Created by Eugene Yatsenko on 11.10.2023.
//

import SwiftUI
import Core
import AuthenticationServices
import FacebookLogin
import GoogleSignIn
import MSAL
import Swinject

enum SocialAuthDetails {
    case apple(SocialAuthResponse)
    case facebook(SocialAuthResponse)
    case google(SocialAuthResponse)
    case microsoft(SocialAuthResponse)

    var backend: String {
        switch self {
        case .apple:
           "apple-id"
        case .facebook:
            "facebook"
        case .google:
            "google-oauth2"
        case .microsoft:
            "azuread-oauth2"
        }
    }
    
    var authMethod: AuthMethod {
        switch self {
        case .apple:
            .socailAuth(.apple)
        case .facebook:
            .socailAuth(.facebook)
        case .google:
            .socailAuth(.google)
        case .microsoft:
            .socailAuth(.microsoft)
        }
    }

    var response: SocialAuthResponse {
        switch self {
        case .apple(let response),
             .facebook(let response),
             .google(let response),
             .microsoft(let response):
            return response
        }
    }
}

final class SocialAuthViewModel: ObservableObject {

    // MARK: - Properties

    private var completion: ((SocialAuthMethod, Result<SocialAuthDetails, SocialAuthError>) -> Void)
    private let config: ConfigProtocol
    private let analytics: AuthorizationAnalytics
    
    let authType: SocialAuthType
    @Published var lastUsedOption: SocialAuthMethod?
    var enabledOptions: [SocialAuthMethod] = []
    
    init(
        config: ConfigProtocol,
        analytics: AuthorizationAnalytics,
        authType: SocialAuthType,
        lastUsedOption: String?,
        completion: @escaping (SocialAuthMethod, Result<SocialAuthDetails, SocialAuthError>) -> Void
    ) {
        self.config = config
        self.analytics = analytics
        self.authType = authType
        self.completion = completion
        if let lastUsedOption {
            self.lastUsedOption = SocialAuthMethod(rawValue: lastUsedOption)
        }
        
        configureEnabledOptions()
    }

    private lazy var appleAuthProvider: AppleAuthProvider  = .init(config: config)
    private lazy var googleAuthProvider: GoogleAuthProvider = .init()
    private lazy var facebookAuthProvider: FacebookAuthProvider = .init()
    private lazy var microsoftAuthProvider: MicrosoftAuthProvider = .init()

    private var topViewController: UIViewController? {
        UIApplication.topViewController()
    }

    // MARK: - Public Properties

    var faceboolEnabled: Bool {
        config.facebook.enabled
    }

    var googleEnabled: Bool {
        config.google.enabled
    }

    var microsoftEnabled: Bool {
        config.microsoft.enabled
    }

    var appleSignInEnabled: Bool {
        if faceboolEnabled ||
            googleEnabled ||
            microsoftEnabled {
            /// Apps that use a third-party or social login service (such as Facebook Login, Google Sign-In...)
            /// to set up or authenticate the user's primary account with the app
            /// must also offer Sign in with Apple as an equivalent option
            return true
        }
        return config.appleSignIn.enabled
    }
    
    func configureEnabledOptions() {
        if googleEnabled {
            enabledOptions.append(.google)
        }
        
        if microsoftEnabled {
            enabledOptions.append(.microsoft)
        }
        
        if faceboolEnabled {
            enabledOptions.append(.facebook)
        }
        
        if appleSignInEnabled {
            enabledOptions.append(.apple)
        }
    }

    // MARK: - Public Intens

    func signInWithApple() {
        trackClickEvent(for: .apple)
        
        appleAuthProvider.request { [weak self] result in
            guard let self else { return }
            result.success { self.success(with: .apple, details: .apple($0)) }
            result.failure { self.failure(with: .apple, error: $0) }
        }
    }

    @MainActor
    func signInWithGoogle() async {
        guard let vc = topViewController else {
            return
        }
        trackClickEvent(for: .google)
        
        let result = await googleAuthProvider.signIn(withPresenting: vc)
        result.success { success(with: .google, details: .google($0)) }
        result.failure { failure(with: .google, error: $0) }
    }

    @MainActor
    func signInWithFacebook() async {
        guard let vc = topViewController else {
            return
        }
        trackClickEvent(for: .facebook)
        
        let result = await facebookAuthProvider.signIn(withPresenting: vc)
        result.success { success(with: .facebook, details: .facebook($0)) }
        result.failure { failure(with: .facebook, error: $0) }
    }

    @MainActor
    func signInWithMicrosoft() async {
        guard let vc = topViewController else {
            return
        }
        trackClickEvent(for: .microsoft)
        
        let result = await microsoftAuthProvider.signIn(withPresenting: vc)
        result.success { success(with: .microsoft, details: .microsoft($0)) }
        result.failure { failure(with: .microsoft, error: $0) }
    }

    private func success(with method: SocialAuthMethod, details: SocialAuthDetails) {
        completion(method, .success(details))
    }

    private func failure(with method: SocialAuthMethod, error: SocialAuthError) {
        completion(method, .failure(error))
    }

    // MARK: - Analytics
    
    private func trackClickEvent(for method: SocialAuthMethod) {
        let analyticsValue = AuthMethod.socailAuth(method).analyticsValue
        
        switch authType {
        case .signIn:
            analytics.userSignInClicked(method: analyticsValue)
        case .register:
            analytics.socialRegisterClicked(method: analyticsValue)
        }
    }
}
