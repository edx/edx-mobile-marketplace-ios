//
//  EDXNetworkServiceProtocol.swift
//  EDXIAPService
//
//  Created by Anton Yarmolenka on 08/04/2025.
//

import Foundation

enum ErrorResponse: String {
    case invalidEndpoint    = "Invalid Endpoint"
    case invalidResponse    = "Invalid Response"
    case invalidStatusCode  = "Invalid Status Code"
    case noData             = "No Data"
    case serializationError = "Serialization Error"
}

protocol EDXNetworkService: Sendable {
    func request<Request: EDXDataRequest & Sendable>(_ request: Request) async throws -> Request.Response
}
