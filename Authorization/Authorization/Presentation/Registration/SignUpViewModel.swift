//
//  SignUpViewModel.swift
//  Authorization
//
//  Created by  Stepanok Ivan on 24.10.2022.
//

import Foundation
import Core
import OEXFoundation
import SwiftUI
import AuthenticationServices
import FacebookLogin
import GoogleSignIn
import MSAL

@MainActor
public final class SignUpViewModel: ObservableObject {
    
    @Published var isShowProgress = false
    @Published var scrollTo: Int?
    @Published var showError: Bool = false
    @Published var thirdPartyAuthSuccess: Bool = false
    let sourceScreen: LogistrationSourceScreen
    
    var errorMessage: String? {
        didSet {
            withAnimation {
                showError = errorMessage != nil
            }
        }
    }
    
    @Published var fields: [FieldConfiguration] = []
    var requiredFields: [FieldConfiguration] {
       fields.filter {
                $0.field.required &&
                !$0.field.isHonorCode &&
                $0.field.type != .checkbox
            }
    }
    var agreementsFields: [FieldConfiguration] {
        fields.filter {
            $0.field.isHonorCode ||
            $0.field.type == .checkbox
        }
    }
    var optionalFields: [FieldConfiguration] {
        fields.filter { !$0.field.required }
    }

    let router: AuthorizationRouter
    let config: ConfigProtocol
    let cssInjector: CSSInjector
    
    private let interactor: AuthInteractorProtocol
    private let analytics: AuthorizationAnalytics
    private let validator: Validator
    var authMethod: AuthMethod = .password
    let storage: CoreStorage

    public init(
        interactor: AuthInteractorProtocol,
        router: AuthorizationRouter,
        analytics: AuthorizationAnalytics,
        config: ConfigProtocol,
        cssInjector: CSSInjector,
        validator: Validator,
        storage: CoreStorage,
        sourceScreen: LogistrationSourceScreen
    ) {
        self.interactor = interactor
        self.router = router
        self.analytics = analytics
        self.config = config
        self.cssInjector = cssInjector
        self.validator = validator
        self.storage = storage
        self.sourceScreen = sourceScreen
    }

    var socialAuthEnabled: Bool {
        let socialLoginEnabled = config.appleSignIn.enabled ||
        config.facebook.enabled ||
        config.microsoft.enabled ||
        config.google.enabled
        return socialLoginEnabled && !thirdPartyAuthSuccess && !isShowProgress
    }
    
    lazy var socialAuthViewModel = SocialAuthViewModel(
        config: config,
        analytics: analytics,
        authType: .register,
        lastUsedOption: storage.lastUsedSocialAuth,
        completion: { [weak self] method, result in
            guard let self else { return }
            
            Task {
                await self.register(with: method, result: result)
            }
        }
    )

    private func showErrors(errors: [String: String]) -> Bool {
        if thirdPartyAuthSuccess, !errors.map({ $0.value }).filter({ !$0.isEmpty }).isEmpty {
            scrollTo = 1
            return true
        }

        var containsError = false
        errors.forEach { key, value in
            if let index = fields.firstIndex(where: { $0.field.name == key }) {
                fields[index].error = value
                if value.count > 0 { containsError = true }
            }
        }
        scrollTo = fields.firstIndex(where: {$0.error != ""})
        return containsError
    }
    
    @MainActor
    public func getRegistrationFields() async {
        isShowProgress = true
        do {
            let fields = try await interactor.getRegistrationFields()
            self.fields = fields.map { FieldConfiguration(field: $0) }
            isShowProgress = false
        } catch let error {
            isShowProgress = false
            if error.isInternetError {
                errorMessage = CoreLocalization.Error.slowOrNoInternetConnection
            } else if error.isUpdateRequeiredError {
                router.showUpdateRequiredView(showAccountLink: false)
            } else {
                errorMessage = CoreLocalization.Error.unknownError
            }
        }
    }

    private var externalToken: String?
    private var backend: String?

    @MainActor
    func registerUser(authMetod: AuthMethod = .password) async {
        let validateFields = configureFields()
        do {
            let errors = try await interactor.validateRegistrationFields(fields: validateFields)
            if showErrors(errors: errors) {
                analytics.validationFailure(
                    method: authMetod.analyticsValue,
                    statusCode: nil,
                    errorMessage: errors.toJson()
                )
                return
            }
        } catch {
            displayError(error)
            analytics.validationFailure(
                method: authMetod.analyticsValue,
                statusCode: (error as? CustomValidationError)?.statusCode,
                errorMessage: errorMessage
            )
            return
        }
        
        do {
            isShowProgress = true
            let user = try await interactor.registerUser(
                fields: validateFields,
                isSocial: externalToken != nil
            )
            analytics.identify(id: "\(user.id)", username: user.username, email: user.email)
            analytics.registrationSuccess(method: authMetod.analyticsValue)
            isShowProgress = false
            var postLoginData: PostLoginData?
            if case .socialAuth(let socialMethod) = authMethod {
                postLoginData = PostLoginData(authMethod: socialMethod.rawValue, showSocialRegisterBanner: false)
            }
            router.showMainOrWhatsNewScreen(sourceScreen: sourceScreen, postLoginData: postLoginData)
            NotificationCenter.default.post(name: .userAuthorized, object: nil)
        } catch let error {
            isShowProgress = false
            displayError(error)
            analytics.registerFailure(
                method: authMetod.analyticsValue,
                errorCode: nil,
                errorMessage: errorMessage
            )
        }
    }

    private func configureFields() -> [String: String] {
        var validateFields: [String: String] = [:]
        fields.forEach { validateFields[$0.field.name] = $0.text }
        validateFields["honor_code"] = "true"
        validateFields["terms_of_service"] = "true"
        if let externalToken = externalToken, let backend = backend {
            validateFields["access_token"] = externalToken
            validateFields["provider"] = backend
            validateFields["client_id"] = config.oAuthClientId
            if validateFields.contains(where: {$0.key == "password"}) {
                validateFields.removeValue(forKey: "password")
            }
            fields.removeAll { $0.field.type == .password }
        }
        return validateFields
    }
    
    private func displayError(_ error: Error) {
        if case APIError.invalidGrant = error {
            errorMessage = CoreLocalization.Error.invalidCredentials
        } else if error.isInternetError {
            errorMessage = CoreLocalization.Error.slowOrNoInternetConnection
        } else {
            errorMessage = CoreLocalization.Error.unknownError
        }
    }

    @MainActor
    func register(with method: SocialAuthMethod, result: Result<SocialAuthDetails, SocialAuthError>) async {
        switch result {
        case .success(let result):
            analytics.socialAuthSuccess(method: AuthMethod.socailAuth(method).analyticsValue)
            await loginOrRegister(
                result.response,
                backend: result.backend,
                authMethod: result.authMethod
            )
        case .failure(let error):
            analytics.socialAuthFailure(
                method: AuthMethod.socailAuth(method).analyticsValue,
                errorCode: error.errorCode.flatMap { String($0) },
                errorMessage: error.errorDescription
            )
            errorMessage = error.localizedDescription
        }
    }

    @MainActor
    private func loginOrRegister(
        _ response: SocialAuthResponse,
        backend: String,
        authMethod: AuthMethod
    ) async {
        do {
            isShowProgress = true
            let user = try await interactor.login(externalToken: response.token, backend: backend)
            analytics.identify(id: "\(user.id)", username: user.username, email: user.email)
            analytics.userLogin(method: authMethod)
            isShowProgress = false
            var postLoginData: PostLoginData?
            if case .socialAuth(let socialMethod) = authMethod {
                postLoginData = PostLoginData(authMethod: socialMethod.rawValue, showSocialRegisterBanner: true)
            }
            router.showMainOrWhatsNewScreen(sourceScreen: sourceScreen, postLoginData: postLoginData)
            NotificationCenter.default.post(name: .userAuthorized, object: nil)
        } catch {
            update(fullName: response.name, email: response.email)
            self.externalToken = response.token
            self.backend = backend
            thirdPartyAuthSuccess = true
            isShowProgress = false
            self.authMethod = authMethod
            await registerUser(authMetod: authMethod)
        }
    }
    
    private func update(fullName: String?, email: String?) {
        fields.first(where: { $0.field.type == .email })?.text = email ?? ""
        fields.first(where: { $0.field.name == "name" })?.text = fullName ?? ""
    }

    func trackCreateAccountClicked() {
        analytics.createAccountClicked(method: authMethod.analyticsValue)
    }
    
    func trackScreenEvent() {
        analytics.authTrackScreenEvent(
            .logistrationRegister,
            biValue: .logistrationRegister
        )
    }
}
