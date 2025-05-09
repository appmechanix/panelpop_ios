//
//  NetworkService.swift
//
//
//  Created by Daniel Wylie on 11/02/2025.
//

import Alamofire
import Foundation

internal class NetworkService: @unchecked Sendable {
    private let maxWaitTime = 10.0

    @available(iOS 15.0, macOS 10.15, *)
    func post<T: Encodable & Sendable, RT: Decodable & Sendable>(
        config: PanelPopConfig,
        url: String,
        data: T
    ) async -> Result<RT, AFError> {
        let url = try! buildUrl(config, url)

        let task = AF
            .request(url, method: .post, parameters: data, encoder: JSONParameterEncoder.default, headers: self.buildHeaders(config))
            .serializingDecodable(RT.self)

        return await task.result
    }

    private func buildHeaders(_ config: PanelPopConfig) -> HTTPHeaders {
        let headers: HTTPHeaders = [
            "AppKey": config.appKey,
        ]

        return headers
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
