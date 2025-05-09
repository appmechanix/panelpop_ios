//
//  PanelPopContentBuilder.swift
//  PanelPop
//
//  Created by Daniel Wylie on 09/05/2025.
//

import SwiftUI

@available(iOS 15.0, macOS 10.15, *)
class PanelPopContentBuilder {
    private let panel: PanelPopPanel

    init(panel: PanelPopPanel) {
        self.panel = panel
    }

    func buildContent() -> some View {
        VStack(spacing: 16) {
            Text("Your Panel")
        }
    }
}
