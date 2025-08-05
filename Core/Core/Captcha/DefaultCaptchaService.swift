//
//  DefaultCaptchaService.swift
//  Core
//
//  Created by Muhammad Tayyab Akram on 7/25/25.
//

import Foundation
import RecaptchaEnterprise

public final class DefaultCaptchaService: CaptchaService {
    private let siteKey: String
    private let clientLock = NSLock()
    private var clientState: ClientState?

    private enum ClientState {
        case unsupported
        case initializing(_ task: Task<RecaptchaClient, Error>)
        case initialized(_ client: RecaptchaClient)
    }

    private enum CaptchaError: Error {
        case unsupported
    }

    public init(config: ConfigProtocol) {
        self.siteKey = config.recaptcha.siteKey
        self.clientState = config.recaptcha.enabled ? .none : .unsupported
    }

    private func currentState() -> ClientState {
        clientLock.lock()
        defer { clientLock.unlock() }

        if let clientState {
            return clientState
        }

        let clientTask = Task {
            do {
                let client = try await Recaptcha.fetchClient(withSiteKey: self.siteKey)
                setState(.initialized(client))
                return client
            } catch {
                if let error = error as? RecaptchaError {
                    error.debugPrint()
                }
                setState(.none)
                throw error
            }
        }
        let newState = ClientState.initializing(clientTask)
        clientState = newState

        return newState
    }

    private func setState(_ state: ClientState?) {
        clientLock.lock()
        defer { clientLock.unlock() }

        clientState = state
    }

    private func recaptchaClient() async throws -> RecaptchaClient? {
        switch currentState() {
        case .unsupported:
            return nil
        case .initializing(let task):
            return try await task.value
        case .initialized(let client):
            return client
        }
    }

    public func executeCaptcha(action: String, timeout: TimeInterval) async throws -> String {
        guard let client = try await recaptchaClient() else {
            return ""
        }

        do {
            return try await client.execute(
                withAction: .init(customAction: action),
                withTimeout: timeout * 1000
            )
        } catch {
            if let error = error as? RecaptchaError {
                error.debugPrint()
            }
            throw error
        }
    }
}

extension RecaptchaError {
    func debugPrint() {
        Swift.debugPrint("RecaptchaError: Code=\(errorCode), Message=\(errorMessage ?? "")")
    }
}
