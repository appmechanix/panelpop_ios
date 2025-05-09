//
//  PanelPopView.swift
//  PanelPop
//
//  Created by Daniel Wylie on 09/05/2025.
//

import NukeUI
import SwiftUI

@available(iOS 15.0, macOS 10.15, *)
public struct PanelPopView: View {
    private let panel: PanelPopPanel
    private let contentBlocks: ContentBlocks

    public init(_ panel: PanelPopPanel) {
        self.panel = panel

        do {
            let contentSchema = try JSONDecoder().decode(ContentBlocks.self, from: Data(panel.panels[0].schema.utf8))
            self.contentBlocks = contentSchema
        } catch {
            print("Failed to decode ContentBlocks: \(error)")
            self.contentBlocks = ContentBlocks(blocks: []) // Provide a default or empty value
        }
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ScrollView {
                Text("🎉 PanelPop")
                    .font(.title)
                    .bold()

                Text(panel.name)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding()

                ForEach(contentBlocks.blocks, id: \.id) { block in
                    switch block.type {
                    case .paragraph:
                        HStack {
                            Text(block.data.text ?? "No text")
                                .font(.body)
                                .multilineTextAlignment(.leading)
                                .padding()

                            Spacer()
                        }

                    case .header:
                        HStack {
                            Text(block.data.text ?? "No text")
                                .font(.title)
                                .bold()
                                .padding()

                            Spacer()
                        }

                    case .image:
                        HStack {
                            if let url = block.data.file?.url, let validURL = URL(string: url) {
                                LazyImage(url: validURL) { state in
                                    if let image = state.image {
                                        image
                                            .resizable()
                                            .scaledToFit()
                                            .frame(maxWidth: 300)
                                            .cornerRadius(8)
                                    } else if state.error != nil {
                                        Text("Failed to load image")
                                            .foregroundColor(.red)
                                    }
                                }
                                Text(block.data.caption ?? "No caption")
                                    .font(.caption)
                                    .padding()
                            } else {
                                Text("No image URL")
                                    .foregroundColor(.red)
                            }
                        }

                    case .list:
                        if block.data.style == "unordered" {
                            VStack(alignment: .leading) {
                                ForEach(block.data.items ?? [], id: \.content) { item in
                                    HStack {
                                        Circle()
                                            .fill(Color.black)
                                            .frame(width: 8, height: 8)

                                        Text(item.content)

                                        Spacer()
                                    }
                                }
                            }
                            .padding()
                        } else if block.data.style == "ordered" {
                            VStack(alignment: .leading) {
                                ForEach(Array((block.data.items ?? []).enumerated()), id: \.element.content) { index, item in
                                    HStack {
                                        Text("\(index + 1).")
                                            .font(.body)
                                            .fontWeight(.bold)

                                        Text(item.content)

                                        Spacer()
                                    }
                                }
                            }
                            .padding()
                        } else {
                            Text("Unknown list style \(block.data.style ?? "")")
                                .foregroundColor(.red)
                        }

                    default:
                        Text("Unknown block type: \(block.type)")
                            .font(.body)
                            .foregroundColor(.red)
                    }
                }

                Button {
                    print("Button tapped!")
                } label: {
                    Text("Dismiss")
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.gray.opacity(0.2))
                    .shadow(radius: 4)
            )
            .padding()
        }
    }
}

@available(iOS 15.0, macOS 10.15, *)
#Preview {
    let jsonString = """
    {
        "hash": "91ndaz",
        "token": "demo_panel",
        "name": "Demo Panel",
        "platform": 0,
        "lastUpdated": "2025-05-09T03:16:59.882778Z",
        "panels": [
            {
                "name": "Demo Panel",
                "panelType": 0,
                "schema": "{\\"time\\": 1746760619531, \\"blocks\\": [{\\"id\\": \\"tGjMYFC37W\\", \\"data\\": {\\"text\\": \\"This is some text\\"}, \\"type\\": \\"paragraph\\"}, {\\"id\\": \\"ZUToz62mk5\\", \\"data\\": {\\"text\\": \\"This is <i>some</i> text <b>with</b> formatting and a <a href=\\\\\\"https://overlandnavigator.co.nz/\\\\\\">link</a>\\"}, \\"type\\": \\"paragraph\\"}, {\\"id\\": \\"N7-m0kO1bI\\", \\"data\\": {\\"text\\": \\"This is a heading\\", \\"level\\": 2}, \\"type\\": \\"header\\"}, {\\"id\\": \\"JBJMoUzUZQ\\", \\"data\\": {\\"meta\\": {}, \\"items\\": [{\\"meta\\": {}, \\"items\\": [], \\"content\\": \\"This is a list item\\"}, {\\"meta\\": {}, \\"items\\": [], \\"content\\": \\"This is a list item\\"}], \\"style\\": \\"unordered\\"}, \\"type\\": \\"list\\"}, {\\"id\\": \\"c_Quv3QCbL\\", \\"data\\": {\\"meta\\": {\\"counterType\\": \\"numeric\\"}, \\"items\\": [{\\"meta\\": {}, \\"items\\": [], \\"content\\": \\"This is an ordered item\\"}, {\\"meta\\": {}, \\"items\\": [], \\"content\\": \\"This is an ordered item\\"}], \\"style\\": \\"ordered\\"}, \\"type\\": \\"list\\"}, {\\"id\\": \\"m2Yy3OQrtc\\", \\"data\\": {\\"meta\\": {}, \\"items\\": [{\\"meta\\": {\\"checked\\": false}, \\"items\\": [], \\"content\\": \\"This is a checklist\\"}], \\"style\\": \\"checklist\\"}, \\"type\\": \\"list\\"}, {\\"id\\": \\"-TWQQOld_t\\", \\"data\\": {\\"file\\": {\\"url\\": \\"https://static.panelpop.co/0fsd52/0fsd52/91ndaz/1255002b-11d7-4aed-a89b-51794d9b2c4d\\"}, \\"caption\\": \\"This is the caption\\", \\"stretched\\": false, \\"withBorder\\": false, \\"withBackground\\": false}, \\"type\\": \\"image\\"}], \\"version\\": \\"2.31.0-rc.7\\"}",
                "buttons": [
                    {
                        "text": "Close",
                        "icon": "remove",
                        "meta": "closebutton"
                    }
                ],
                "displayType": 0
            }
        ]
    }
    """
    let panelResponseModel = try! JSONDecoder().decode(PanelPopPanel.self, from: Data(jsonString.utf8))

    PanelPopView(
        panelResponseModel
    )
}
