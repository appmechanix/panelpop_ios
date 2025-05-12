//
//  NetworkService.swift
//
//
//  Created by Daniel Wylie on 11/02/2025.
//

import Foundation

internal class NetworkService: @unchecked Sendable {
    private let maxWaitTime = 10.0

    @available(iOS 15.0, macOS 10.15, *)
    func post<T: Encodable & Sendable, RT: Decodable & Sendable>(
        config: PanelPopConfig,
        url: String,
        data: T
    ) async -> Result<RT, PanelPopNetworkError> {
        // Build URL
        guard let postUrl = try? buildUrl(config, url) else {
            return .failure(.invalidURL)
        }

        // Build request
        var request = URLRequest(url: postUrl)
        request.httpMethod = "POST"
        request.timeoutInterval = maxWaitTime
        request.allHTTPHeaderFields = buildHeaders(config)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONEncoder().encode(data)
        } catch {
            return .failure(.encodingError(error))
        }

        do {
            let (responseData, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                return .failure(.transportError(URLError(.badServerResponse)))
            }

            guard (200 ..< 300).contains(httpResponse.statusCode) else {
                return .failure(.httpError(statusCode: httpResponse.statusCode))
            }

            let decoded = try JSONDecoder().decode(RT.self, from: responseData)
            return .success(decoded)

        } catch let decodingError as DecodingError {
            return .failure(.decodingError(decodingError))
        } catch {
            return .failure(.transportError(error))
        }
    }

    private func buildHeaders(_ config: PanelPopConfig) -> [String: String] {
        [
            "AppKey": config.appKey,
        ]
    }

    private func buildUrl(_ config: PanelPopConfig, _ path: String) throws -> URL {
        guard var urlComponents = URLComponents(string: config.apiUrl) else {
            throw URLError(.badURL)
        }
        urlComponents.path = path.hasPrefix("/") ? path : "/" + path

        guard let url = urlComponents.url else {
            throw URLError(.badURL)
        }

        return url
    }
}
