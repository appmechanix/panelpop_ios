//
//  PanelPopConfig.swift
//
//
//  Created by Daniel Wylie on 11/02/2025.
//

import Foundation

public struct PanelPop {
    public static func Initialize(_ appKey: String): PanelPop {
        let config = PanelPopConfig(appKey: appKey)

        // Check if we have an inactive file setup - bascially created when the account or app is
        // no longer valid
        let documentsPath = getDocumentsDirectory()
        if FileManager.default.fileExists(atPath: "\(documentsPath)/\panelpop_inactive.json") {
            config.isActive = false
        }

        return .init(config)
    }

    var config: PanelPopConfig

    init(_ config: PanelPopConfig) {
        self.config = config
    }

    public func ShowPopup(_ token: String) {
    }

    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
