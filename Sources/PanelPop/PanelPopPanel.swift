//
//  PanelResponseModel.swift
//  PanelPop
//
//  Created by Daniel Wylie on 09/05/2025.
//

import Foundation
import SwiftUI

// MARK: - PanelResponseModel

public struct PanelPopPanel: Codable, Sendable {
    let hash, token, name: String
    let platform: Int
    let lastUpdated: String
    let panels: [Panel]
}

// MARK: - Panel

public struct Panel: Codable, Sendable {
    public let name: String
    public let panelType: Int
    public let schema: String
    public let buttons: [PanelPopButton]
    public let displayType: Int
}

// MARK: - Button

public struct PanelPopButton: Codable, Sendable {
    public let text, icon, meta, style: String
}
