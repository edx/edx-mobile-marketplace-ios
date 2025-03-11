//
//  SocialAuthError.swift
//  Core
//
//  Created by Eugene Yatsenko on 10.10.2023.
//

import Foundation
import Core

public enum SocialAuthError: Error {
    case error(code: Int? = nil, text: String)
    case socialAuthCanceled(code: Int? = nil)
    case unknownError(code: Int? = nil)
}

extension SocialAuthError: LocalizedError {
    public var errorCode: Int? {
        switch self {
        case .error(let code, _):
            return code
        case .socialAuthCanceled(let code):
            return code
        case .unknownError(let code):
            return code
        }
    }
    
    public var errorDescription: String? {
        switch self {
        case .error(_, let text):
            return text
        case .socialAuthCanceled:
            return CoreLocalization.socialSignCanceled
        case .unknownError:
            return CoreLocalization.Error.unknownError
        }
    }
}
