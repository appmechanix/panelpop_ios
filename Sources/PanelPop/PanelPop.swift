//
//  PanelPopConfig.swift
//
//
//  Created by Daniel Wylie on 11/02/2025.
//

import Alamofire
import Foundation

@available(iOS 15.0, macOS 10.15, *)
public class PanelPop {
    private var networkService = NetworkService()

    public static func Initialize(_ appKey: String) -> PanelPop {
        var config = PanelPopConfig(appKey: appKey)

        // Check if we have an inactive file setup - bascially created when the account or app is
        // no longer valid
        let documentsPath = getDocumentsDirectory()
        if FileManager.default.fileExists(atPath: "\(documentsPath)/panelpop_inactive.json") {
            config.isActive = false
        }

        return .init(config)
    }

    var config: PanelPopConfig

    init(_ config: PanelPopConfig) {
        self.config = config
    }

    @MainActor
    public func ShowPopup(_ token: String) async -> PanelPopPanel? {
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

        let networkResponse: Result<PanelPopPanel?, AFError> = await self.networkService.post(
            config: config,
            url: "/panels/v1/fetch/\(token)",
            data: requestModel
        )

        switch networkResponse {
        case let .success(response):
            return response

        case let .failure(error):
            print("Error: \(error)")

            if let statusCode = error.responseCode, statusCode == 403 {
                do {
                    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
                    let documentsPath = paths[0]
                    let inactiveFilePath = documentsPath.appendingPathComponent("panelpop_inactive.json")
                    try "{}".write(to: inactiveFilePath, atomically: true, encoding: .utf8)
                    self.config.isActive = false
                } catch {
                    print("Failed to create inactive file: \(error)")
                }
            }

            return nil
        }
    }

    private static func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
