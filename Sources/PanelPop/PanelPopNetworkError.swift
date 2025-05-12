//
//  PanelPopNetworkError.swift
//  PanelPop
//
//  Created by Daniel Wylie on 13/05/2025.
//

enum PanelPopNetworkError: Error {
    case httpError(statusCode: Int)
    case decodingError(Error)
    case encodingError(Error)
    case transportError(Error)
    case invalidURL
}
