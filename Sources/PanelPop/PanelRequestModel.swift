//
//  PanelRequestModel.swift
//  PanelPop
//
//  Created by Daniel Wylie on 09/05/2025.
//

import Foundation

public struct PanelRequestModel: Codable, Sendable {
    let version: String
    let platform: Int = 0

    init(version: String) {
        self.version = version
    }
}
