//
//  DefaultNetworkService.swift
//  EDXIAPService
//
//  Created by Anton Yarmolenka on 08/04/2025.
//

import Foundation

final class DefaultNetworkService: EDXNetworkService {
    func request<Request: EDXDataRequest & Sendable>(_ request: Request) async throws -> Request.Response {
        guard var urlComponent = URLComponents(string: request.url) else {
            throw NSError(
                domain: ErrorResponse.invalidEndpoint.rawValue,
                code: 0,
                userInfo: nil
            )
        }
        
        var queryItems: [URLQueryItem] = []
        
        request.queryItems.forEach {
            let urlQueryItem = URLQueryItem(name: $0.key, value: $0.value)
            urlComponent.queryItems?.append(urlQueryItem)
            queryItems.append(urlQueryItem)
        }
        
        urlComponent.queryItems = queryItems
        
        guard let url = urlComponent.url else {
            throw NSError(
                domain: ErrorResponse.invalidEndpoint.rawValue,
                code: 0,
                userInfo: nil
            )
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.allHTTPHeaderFields = request.headers
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
            throw NSError(
                domain: ErrorResponse.invalidStatusCode.rawValue,
                code: (response as? HTTPURLResponse)?.statusCode ?? 0,
                userInfo: nil
            )
        }
        
        return try request.decode(data)
    }
}
