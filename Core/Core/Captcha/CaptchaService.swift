//
//  CaptchaService.swift
//  Core
//
//  Created by Muhammad Tayyab Akram on 7/24/25.
//

import Foundation

public protocol CaptchaService {
    func executeCaptcha(action: String, timeout: TimeInterval) async throws -> String
}

#if DEBUG
public final class CaptchaServiceMock: CaptchaService {
    public init() {}

    public func executeCaptcha(action: String, timeout: TimeInterval) async throws -> String {
        return "token"
    }
}
#endif
