//
//  PanelPopView.swift
//  PanelPop
//
//  Created by Daniel Wylie on 09/05/2025.
//

import SwiftUI

@available(iOS 15.0, macOS 10.15, *)
public struct PanelPopView: View {
    private let token: String

    @State private var panel: PanelPopPanel?
    @State private var contentBlocks: ContentBlocks?

    public var onCloseButtonTapped: () -> Void
    public var onButtonTapped: ((PanelPopButton) -> Void)?

    public init(
        _ token: String,
        onCloseButtonTapped: @escaping () -> Void
    ) {
        self.token = token
        self.onCloseButtonTapped = onCloseButtonTapped
    }

    public init(
        _ token: String,
        onCloseButtonTapped: @escaping () -> Void,
        onButtonTapped: ((PanelPopButton) -> Void)?
    ) {
        self.token = token
        self.onCloseButtonTapped = onCloseButtonTapped
        self.onButtonTapped = onButtonTapped
    }

    public init(
        _ panel: PanelPopPanel,
        onCloseButtonTapped: @escaping () -> Void
    ) {
        self.token = panel.token
        self.onCloseButtonTapped = onCloseButtonTapped

        _panel = State(initialValue: panel)

        let contentSchema: ContentBlocks
        do {
            contentSchema = try JSONDecoder().decode(ContentBlocks.self, from: Data(panel.panels[0].schema.utf8))
        } catch {
            print("Failed to decode ContentBlocks: \(error)")
            contentSchema = ContentBlocks.ErrorMode()
        }
        _contentBlocks = State(initialValue: contentSchema)
    }

    func loadPanelIfNeeded() async {
        guard self.panel == nil else { return }

        if let loadedPanel = await PanelPop.getPopup(token: token) {
            self.panel = loadedPanel

            do {
                let contentSchema = try JSONDecoder().decode(ContentBlocks.self, from: Data(loadedPanel.panels[0].schema.utf8))
                self.contentBlocks = contentSchema
            } catch {
                print("Failed to decode ContentBlocks: \(error)")
                self.contentBlocks = ContentBlocks.ErrorMode()
            }
        } else {
            print("Failed to fetch panel")
        }
    }

    private var backgroundColor: Color {
        #if os(iOS)
            return Color(uiColor: UIColor.systemBackground)
        #elseif os(macOS)
            return Color(nsColor: NSColor.windowBackgroundColor)
        #endif
    }

    var platformLinkColor: Any {
        #if os(iOS)
            return UIColor.link
        #else
            return NSColor.linkColor
        #endif
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text(panel?.name ?? "Loading...")
                    .font(.headline)
                    .padding(.leading)

                Spacer()

                Button {
                    self.onCloseButtonTapped()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                        .imageScale(.large)
                        .padding()
                }
            }
            .background(Color(.tertiarySystemFill))

            // Main Content
            if let panel = panel, let contentBlocks = contentBlocks {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        ForEach(contentBlocks.blocks, id: \.id) { block in
                            switch block.type {
                            case .paragraph:
                                HStack {
                                    if let html = block.data.text,
                                       let data = html.data(using: .utf8),
                                       let raw = try? NSMutableAttributedString(
                                           data: data,
                                           options: [
                                               .documentType: NSAttributedString.DocumentType.html,
                                               .characterEncoding: String.Encoding.utf8.rawValue,
                                           ],
                                           documentAttributes: nil
                                       ) {
                                        // Convert to AttributedString (cross-platform)
                                        if let cleaned = try? AttributedString(raw, including: AttributeScopes.FoundationAttributes.self) {
                                            HStack {
                                                Text(cleaned)
                                                    .font(.body)
                                                    .multilineTextAlignment(.leading)
                                                    .padding(.vertical, 8)

                                                Spacer()
                                            }
                                        }
                                    }

                                    Spacer()
                                }

                            case .header:
                                HStack {
                                    Text(block.data.text ?? "No text")
                                        .font(.title)
                                        .bold()
                                        .padding(.vertical, 8)

                                    Spacer()
                                }

                            case .image:
                                VStack(alignment: .center) {
                                    if let url = block.data.file?.url, let validURL = URL(string: url) {
                                        AsyncImage(url: validURL) { phase in
                                            switch phase {
                                            case .empty:
                                                ProgressView()
                                                    .frame(maxWidth: .infinity)
                                            case let .success(image):
                                                image
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(maxWidth: .infinity)
                                                    .cornerRadius(8)
                                            case .failure:
                                                Text("Failed to load image")
                                                    .foregroundColor(.red)
                                                    .frame(maxWidth: .infinity)
                                            @unknown default:
                                                EmptyView()
                                            }
                                        }

                                        Text(block.data.caption ?? "No caption")
                                            .font(.caption)
                                            .padding(.vertical, 8)
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
                                    .padding(.vertical, 8)
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
                                    .padding(.vertical, 8)
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
                    }
                    .padding()
                }

                // Buttons
                if !panel.panels[0].buttons.isEmpty {
                    HStack {
                        ForEach(panel.panels[0].buttons, id: \.text) { button in
                            if button.style == "primary" {
                                Button {
                                    onButtonTapped?(button)
                                } label: {
                                    Text(button.text)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(.borderedProminent)
                            } else {
                                Button {
                                    onButtonTapped?(button)
                                } label: {
                                    Text(button.text)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(.bordered)
                            }
                        }
                    }
                    .padding()
                    .background(
                        backgroundColor
                            .overlay(Divider(), alignment: .top)
                    )
                }
            } else {
                // Loading View
                VStack(alignment: .center, spacing: 16) {
                    Spacer()
                    ProgressView()
                        .scaleEffect(2)
                        .padding()
                    Spacer()
                }
            }
        }
        .task { @MainActor in
            await loadPanelIfNeeded()
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
                        "text": "Not now",
                        "icon": "remove",
                        "meta": "closebutton",
                        "style": "secondary"
                    },
                    {
                        "text": "Upgrade now",
                        "icon": "remove",
                        "meta": "upgradenow",
                        "style": "primary"
                    }
                ],
                "displayType": 0
            }
        ]
    }
    """
    let panelResponseModel = try! JSONDecoder().decode(PanelPopPanel.self, from: Data(jsonString.utf8))

    PanelPopView(
        panelResponseModel,
        onCloseButtonTapped: {
            print("Closed")
        }
    )
}

@available(iOS 15.0, macOS 10.15, *)
#Preview {
    PanelPopView("demo_panel") {
        print("Closed")
    }
}
