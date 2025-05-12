//
//  PanelPopConfig.swift
//
//
//  Created by Daniel Wylie on 11/02/2025.
//

import Foundation

@MainActor
public final class PanelPopManager {
    private var config: PanelPopConfig
    private lazy var networkService = NetworkService()

    init(apiKey: String) {
        self.config = PanelPopConfig(appKey: apiKey)
    }

    public func getPopup(token: String) async -> PanelPopPanel? {
        // Check if the app is active
        guard config.isActive else {
            print("PanelPop is inactive")
            return nil
        }

        // Check if we have a token
        guard !token.isEmpty else {
            print("No token provided")
            return nil
        }

        let requestModel = PanelRequestModel(version: "1.0")

        let networkResponse: Result<PanelPopPanel?, PanelPopNetworkError> = await self.networkService.post(
            config: config,
            url: "/panels/v1/fetch/\(token)",
            data: requestModel
        )

        switch networkResponse {
        case let .success(response):
            return response

        case let .failure(error):
            if case let .httpError(statusCode) = error, statusCode == 403 {
                do {
                    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
                    let documentsPath = paths[0]
                    let inactiveFilePath = documentsPath.appendingPathComponent("panelpop_inactive.json")
                    try "{}".write(to: inactiveFilePath, atomically: true, encoding: .utf8)
                    self.config.isActive = false
                } catch {
                    print("Failed to create inactive file: \(error)")
                }
            } else {
                print("Other error: \(error)")
            }
        }
        
        return nil
    }
}

@available(iOS 15.0, macOS 10.15, *)
@MainActor
public enum PanelPop {
    private static var shared: PanelPopManager?

    public static func initialize(_ apiKey: String) {
        self.shared = PanelPopManager(apiKey: apiKey)
    }

    public static func getPopup(token: String) async -> PanelPopPanel? {
        guard let shared = self.shared else {
            print("PanelPop not initialized")
            return nil
        }

        return await shared.getPopup(token: token)
    }
}
