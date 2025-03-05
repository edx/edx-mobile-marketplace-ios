//
//  MicrosoftAuthProvider.swift
//  Core
//
//  Created by Eugene Yatsenko on 10.10.2023.
//

import Foundation
import MSAL
import Swinject

public typealias MSLoginCompletionHandler = (account: MSALAccount, token: String)

public final class MicrosoftAuthProvider {

    private let scopes = ["User.Read", "email"]
    private var result: MSALResult?

    public init() {}

    @MainActor
    public func signIn(
        withPresenting: UIViewController
    ) async -> Result<SocialAuthResponse, SocialAuthError> {
        await withCheckedContinuation { continuation in
            do {
                let clientApplication = try createClientApplication()

                let webParameters = MSALWebviewParameters(authPresentationViewController: withPresenting)
                let parameters = MSALInteractiveTokenParameters(scopes: scopes, webviewParameters: webParameters)
                clientApplication.acquireToken(with: parameters) {  result, error in
                    if let error = error {
                        continuation.resume(
                            returning: .failure(
                                SocialAuthError.error(
                                    code: (error as NSError).code,
                                    text: error.localizedDescription
                                )
                            )
                        )
                        return
                    }

                    guard let result = result else {
                        continuation.resume(
                            returning: .failure(
                                SocialAuthError.unknownError()
                            )
                        )
                        return
                    }

                    self.result = result
                    let account = result.account

                    continuation.resume(
                        returning: .success(
                            SocialAuthResponse(
                                name: account.accountClaims?["name"] as? String ?? "",
                                email: account.accountClaims?["email"] as? String ?? "",
                                token: result.accessToken
                            )
                        )
                    )
                }
            } catch let error {
                continuation.resume(
                    returning: .failure(
                        SocialAuthError.error(
                            code: (error as NSError).code,
                            text: error.localizedDescription
                        )
                    )
                )
            }
        }
    }

    public func signOut() {
        do {
            let account = try? currentAccount()

            if let account = account {
                let application = try createClientApplication()
                try application.remove(account)
            }
        } catch let error {
            debugLog("Logout", "Received error signing user out: \(error)")
        }
    }

    private func createClientApplication() throws -> MSALPublicClientApplication {
        guard let config = Container.shared.resolve(ConfigProtocol.self),
              let clientID =  config.microsoft.clientID else {
            throw SocialAuthError.error(text: "Configuration error")
        }
        let configuration = MSALPublicClientApplicationConfig(clientId: clientID)

        do {
            return try MSALPublicClientApplication(configuration: configuration)
        } catch {
            throw SocialAuthError.error(
                code: (error as NSError).code,
                text: error.localizedDescription
            )
        }
    }

    @discardableResult
    private func currentAccount() throws -> MSALAccount {
        let clientApplication = try createClientApplication()

        guard let account = try clientApplication.allAccounts().first else {
            throw SocialAuthError.error(text: "Account not found")
        }

        return account
    }
    
    func getUser(completion: (MSALAccount) -> Void) {
        guard let user = result?.account else { return }
        completion(user)
    }

}
