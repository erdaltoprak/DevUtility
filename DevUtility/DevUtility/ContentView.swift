import SwiftUI

struct ContentView: View {
    @State private var path: [Tool] = []
    @State private var selectedTool: Tool? = Tool.allTools.first
    #if os(macOS)
        @Binding private var columnVisibility: NavigationSplitViewVisibility
    #endif

    #if os(macOS)
        init(columnVisibility: Binding<NavigationSplitViewVisibility>) {
            _columnVisibility = columnVisibility
        }
    #endif

    var body: some View {
        #if os(macOS)
            NavigationSplitView(columnVisibility: $columnVisibility) {
                ToolSidebarView(selectedTool: $selectedTool)
                    .navigationSplitViewColumnWidth(min: 260, ideal: 320, max: 420)
            } detail: {
                if let tool = selectedTool {
                    ToolDetailView(tool: tool)
                } else {
                    ToolPlaceholderView()
                }
            }
            .navigationTitle("DevUtility")
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    SettingsLink {
                        Image(systemName: "gearshape")
                    }
                }
            }
        #else
            NavigationStack(path: $path) {
                ToolListView { tool in
                    path.append(tool)
                }
                .navigationTitle("DevUtility")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        NavigationLink {
                            SettingsView()
                        } label: {
                            Image(systemName: "gearshape")
                        }
                    }
                }
                .navigationDestination(for: Tool.self) { tool in
                    ToolDetailView(tool: tool)
                }
            }
        #endif
    }
}

#Preview {
    let settings = SettingsStore()
    let clipboardService = ClipboardService()

    #if os(macOS)
        let previewView = ContentView(columnVisibility: .constant(.all))
    #else
        let previewView = ContentView()
    #endif

    return
        previewView
        .environment(settings)
        .environment(settings.theme)
        .environment(clipboardService)
}

// MARK: - Tool Model

extension ContentView {
    struct Tool: Identifiable, Hashable {
        enum Category: String, Hashable, CaseIterable {
            case converters
            case formatters
            case encodersDecoders
            case textUtilities
            case inspection
            case other

            var title: String {
                switch self {
                case .converters:
                    "Converters"
                case .formatters:
                    "Formatters"
                case .encodersDecoders:
                    "Encoders / Decoders"
                case .textUtilities:
                    "Text Utilities"
                case .inspection:
                    "Inspection"
                case .other:
                    "Other"
                }
            }
        }

        let id: String
        let name: String
        let iconSystemName: String
        let category: Category
        let shortDescription: String

        static var toolsByCategory: [(Category, [Tool])] {
            let grouped = Dictionary(grouping: pocTools, by: { $0.category })
            return Category.allCases.compactMap { category in
                guard let tools = grouped[category] else { return nil }
                return (category, tools)
            }
        }

        /// Tools that are in scope for the current POC (see TODO.md Tools section).
        static let pocTools: [Tool] = [
            // Core POC tools (see TODO.md Tools section)
            .init(
                id: "unix-timestamp-converter",
                name: "Unix Timestamp Converter",
                iconSystemName: "clock.arrow.2.circlepath",
                category: .converters,
                shortDescription: "Convert between Unix timestamps and human‑readable dates."
            ),
            .init(
                id: "base64-encoder-decoder",
                name: "Base64 Encoder/Decoder",
                iconSystemName: "arrow.left.arrow.right.circle",
                category: .encodersDecoders,
                shortDescription: "Encode and decode Base64 strings."
            ),
            .init(
                id: "lorem-ipsum-generator",
                name: "Lorem Ipsum Generator",
                iconSystemName: "text.alignleft",
                category: .textUtilities,
                shortDescription: "Generate placeholder text for layouts and tests."
            ),
            .init(
                id: "text-diff-checker",
                name: "Text Diff Checker",
                iconSystemName: "square.split.2x1",
                category: .inspection,
                shortDescription: "Compare two pieces of text and highlight differences."
            ),
        ]

        /// Optional tools that are not yet part of the POC, but are planned
        /// for future iterations (see TODO.md Optional tools section).
        static let optionalTools: [Tool] = [
            .init(
                id: "json-formatter-validator",
                name: "JSON Formatter & Validator",
                iconSystemName: "curlybraces",
                category: .formatters,
                shortDescription: "Pretty‑print and validate JSON payloads."
            ),
            .init(
                id: "regexp-tester",
                name: "RegExp Tester",
                iconSystemName: "text.magnifyingglass",
                category: .inspection,
                shortDescription: "Test regular expressions against sample input."
            ),
            .init(
                id: "jwt-debugger",
                name: "JWT Debugger",
                iconSystemName: "lock.shield",
                category: .inspection,
                shortDescription: "Decode and inspect JSON Web Tokens."
            ),
            .init(
                id: "url-encoder-decoder",
                name: "URL Encoder/Decoder",
                iconSystemName: "link",
                category: .encodersDecoders,
                shortDescription: "Percent‑encode or decode URL strings."
            ),
            .init(
                id: "query-string-parser",
                name: "Query String Parser",
                iconSystemName: "list.bullet.rectangle.portrait",
                category: .inspection,
                shortDescription: "Parse query strings into key‑value pairs."
            ),
            .init(
                id: "html-entity-encoder-decoder",
                name: "HTML Entity Encoder/Decoder",
                iconSystemName: "chevron.left.forwardslash.chevron.right",
                category: .encodersDecoders,
                shortDescription: "Convert characters to and from HTML entities."
            ),
            .init(
                id: "backslash-escaper-unescaper",
                name: "Backslash Escaper/Unescaper",
                iconSystemName: "repeat",
                category: .textUtilities,
                shortDescription: "Escape or unescape characters with backslashes."
            ),
            .init(
                id: "uuid-generator-decoder",
                name: "UUID Generator/Decoder",
                iconSystemName: "rectangle.and.pencil.and.ellipsis",
                category: .converters,
                shortDescription: "Generate UUIDs and inspect their variants."
            ),
            .init(
                id: "html-preview",
                name: "HTML Preview",
                iconSystemName: "safari",
                category: .inspection,
                shortDescription: "Render HTML content for quick previews."
            ),
            .init(
                id: "html-beautifier-minifier",
                name: "HTML Beautifier/Minifier",
                iconSystemName: "chevron.left.forwardslash.chevron.right",
                category: .formatters,
                shortDescription: "Format or minify HTML markup."
            ),
            .init(
                id: "css-beautifier-minifier",
                name: "CSS Beautifier/Minifier",
                iconSystemName: "curlybraces.square",
                category: .formatters,
                shortDescription: "Format or minify CSS stylesheets."
            ),
            .init(
                id: "js-beautifier-minifier",
                name: "JS Beautifier/Minifier",
                iconSystemName: "chevron.left.forwardslash.chevron.right",
                category: .formatters,
                shortDescription: "Format or minify JavaScript code."
            ),
            .init(
                id: "xml-beautifier-minifier",
                name: "XML Beautifier/Minifier",
                iconSystemName: "doc.text.magnifyingglass",
                category: .formatters,
                shortDescription: "Format or minify XML documents."
            ),
            .init(
                id: "yaml-to-json",
                name: "YAML → JSON Converter",
                iconSystemName: "arrow.triangle.2.circlepath",
                category: .converters,
                shortDescription: "Convert YAML to JSON."
            ),
            .init(
                id: "json-to-yaml",
                name: "JSON → YAML Converter",
                iconSystemName: "arrow.triangle.2.circlepath",
                category: .converters,
                shortDescription: "Convert JSON to YAML."
            ),
            .init(
                id: "number-base-converter",
                name: "Number Base Converter",
                iconSystemName: "number",
                category: .converters,
                shortDescription: "Convert numbers between bases (binary, decimal, hex, etc.)."
            ),
            .init(
                id: "qr-code-generator",
                name: "QR Code Generator",
                iconSystemName: "qrcode",
                category: .other,
                shortDescription: "Create QR codes from input text."
            ),
            .init(
                id: "string-inspector",
                name: "String Inspector",
                iconSystemName: "textformat.alt",
                category: .inspection,
                shortDescription: "Inspect strings as bytes, Unicode scalars, and more."
            ),
            .init(
                id: "hash-generator",
                name: "Hash Generator",
                iconSystemName: "shield.lefthalf.filled.badge.checkmark",
                category: .other,
                shortDescription: "Generate hashes (MD5, SHA, etc.) for input text."
            ),
            .init(
                id: "html-svg-to-jsx",
                name: "HTML/SVG → JSX Converter",
                iconSystemName: "chevron.left.forwardslash.chevron.right",
                category: .converters,
                shortDescription: "Convert HTML or SVG snippets into JSX."
            ),
            .init(
                id: "markdown-preview",
                name: "Markdown Preview",
                iconSystemName: "text.book.closed",
                category: .inspection,
                shortDescription: "Render Markdown to a styled preview."
            ),
            .init(
                id: "sql-formatter",
                name: "SQL Formatter",
                iconSystemName: "tablecells",
                category: .formatters,
                shortDescription: "Format SQL queries for readability."
            ),
            .init(
                id: "string-case-converter",
                name: "String Case Converter",
                iconSystemName: "textformat",
                category: .textUtilities,
                shortDescription: "Convert strings between common case styles."
            ),
        ]

        /// All known tools (POC + optional). Currently only `pocTools` are
        /// surfaced in the UI; `optionalTools` are kept for future expansion.
        static let allTools: [Tool] = pocTools + optionalTools
    }
}

// MARK: - Views

extension ContentView {
    struct ToolListView: View {
        let onSelectTool: (Tool) -> Void

        @Environment(SettingsStore.self) private var settingsStore

        private var toolsByCategory: [(Tool.Category, [Tool])] {
            Tool.toolsByCategory
        }

        var body: some View {
            List {
                ForEach(toolsByCategory, id: \.0) { category, tools in
                    Section(category.title) {
                        ForEach(tools) { tool in
                            Button {
                                settingsStore.markToolUsed(id: tool.id)
                                onSelectTool(tool)
                            } label: {
                                ToolRowView(tool: tool)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
    }

    struct ToolSidebarView: View {
        @Binding var selectedTool: Tool?

        @Environment(SettingsStore.self) private var settingsStore

        private var toolsByCategory: [(Tool.Category, [Tool])] {
            Tool.toolsByCategory
        }

        var body: some View {
            List(selection: $selectedTool) {
                ForEach(toolsByCategory, id: \.0) { category, tools in
                    Section(category.title) {
                        ForEach(tools) { tool in
                            ToolRowView(tool: tool)
                                .tag(tool)
                        }
                    }
                }
            }
            .onChange(of: selectedTool) { _, newValue in
                if let tool = newValue {
                    settingsStore.markToolUsed(id: tool.id)
                }
            }
        }
    }

    struct ToolRowView: View {
        let tool: Tool

        var body: some View {
            HStack(spacing: 12) {
                Image(systemName: tool.iconSystemName)
                    .imageScale(.large)
                    .foregroundStyle(.tint)

                VStack(alignment: .leading, spacing: 4) {
                    Text(tool.name)
                        .bold()
                    Text(tool.shortDescription)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }

                Spacer(minLength: 0)
            }
            .padding(.vertical, 4)
        }
    }

    struct ToolDetailView: View {
        let tool: Tool

        var body: some View {
            switch tool.id {
            case "lorem-ipsum-generator":
                LoremIpsumGeneratorView(tool: tool)
            case "unix-timestamp-converter":
                UnixTimestampConverterView(tool: tool)
            case "base64-encoder-decoder":
                Base64EncoderDecoderView(tool: tool)
            case "text-diff-checker":
                TextDiffCheckerView(tool: tool)
            default:
                ToolUnderConstructionView(tool: tool)
            }
        }
    }

    struct ToolUnderConstructionView: View {
        let tool: Tool
        @State private var sampleInput = ""
        @State private var sampleOutput = ""

        var body: some View {
            VStack(alignment: .leading, spacing: 16) {
                ToolHeaderView(
                    iconSystemName: tool.iconSystemName,
                    title: tool.name,
                    subtitle: tool.category.title,
                    description: tool.shortDescription
                )

                Text("This tool is not implemented yet.")
                    .foregroundStyle(.secondary)

                Text(
                    "As tools are implemented, this screen will host the dedicated SwiftUI view for each feature, following the architecture described in Docs/ARCHITECTURE.md."
                )
                .foregroundStyle(.secondary)

                EditorPanel(
                    title: "Input",
                    text: $sampleInput,
                    prompt: "Enter sample input for \(tool.name)"
                )

                OutputPanel(
                    title: "Output",
                    text: sampleOutput,
                    placeholder: "Formatted or converted output will appear here."
                )

                Spacer(minLength: 0)
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
    }

    struct ToolPlaceholderView: View {
        var body: some View {
            Text("Select a tool to get started.")
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    struct SettingsView: View {
        private struct LinkItem: Identifiable {
            let id: String
            let title: String
            let subtitle: String
            let systemImage: String
            let url: URL
        }

        private static func linkURL(_ raw: String) -> URL {
            guard let url = URL(string: raw) else {
                preconditionFailure("Invalid URL: \(raw)")
            }
            return url
        }

        private let links: [LinkItem] = [
            .init(
                id: "github",
                title: "GitHub",
                subtitle: "View the project on GitHub",
                systemImage: "chevron.left.forwardslash.chevron.right",
                url: Self.linkURL("https://github.com/erdaltoprak/DevUtility")
            ),
            .init(
                id: "website",
                title: "Website",
                subtitle: "Visit the developer's website",
                systemImage: "globe",
                url: Self.linkURL("https://erdaltoprak.com")
            ),
            .init(
                id: "x-profile",
                title: "X (Twitter)",
                subtitle: "Follow the developer on X",
                systemImage: "xmark",
                url: Self.linkURL("https://x.com/erdaltoprak")
            ),
        ]

        var body: some View {
            List {
                Section("About") {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("DevUtility")
                            .font(.title2)
                            .bold()
                        Text("A small collection of local developer tools for everyday dev tasks.")
                            .foregroundStyle(.secondary)
                            .font(.subheadline)
                    }
                    .padding(.vertical, 4)
                }

                Section("Links") {
                    ForEach(links) { link in
                        Link(destination: link.url) {
                            HStack(spacing: 12) {
                                Image(systemName: link.systemImage)
                                    .imageScale(.medium)
                                    .foregroundStyle(.tint)
                                    .frame(width: 20, alignment: .center)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(link.title)
                                        .bold()
                                    Text(link.subtitle)
                                        .foregroundStyle(.secondary)
                                        .font(.subheadline)
                                }

                                Spacer(minLength: 0)

                                Image(systemName: "arrow.up.right")
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            #if os(iOS)
                .navigationTitle("Settings")
                .navigationBarTitleDisplayMode(.inline)
                .listStyle(.insetGrouped)
            #else
                .navigationTitle("Settings")
            #endif
        }
    }
}
