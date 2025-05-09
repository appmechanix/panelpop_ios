//
//  PanelResponseModel.swift
//  PanelPop
//
//  Created by Daniel Wylie on 09/05/2025.
//

import Foundation

// MARK: - PanelResponseModel
public struct PanelPopPanel: Codable, Sendable {
    let hash, token, name: String
    let platform: Int
    let lastUpdated: String
    let panels: [Panel]
}

// MARK: - Panel
public struct Panel: Codable, Sendable {
    let name: String
    let panelType: Int
    let schema: String
    let buttons: [PanelPopButton]
    let displayType: Int
}

// MARK: - Button
public struct PanelPopButton: Codable, Sendable {
    let text, icon, meta: String
}
