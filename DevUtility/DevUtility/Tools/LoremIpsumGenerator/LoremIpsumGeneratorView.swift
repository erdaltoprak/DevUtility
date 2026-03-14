import SwiftUI

extension ContentView {
    struct LoremIpsumGeneratorView: View {
        let tool: Tool

        @Environment(ClipboardService.self) private var clipboardService

        @State private var paragraphCount: Int = 3
        @State private var includeClassicOpening: Bool = true
        @State private var output: String = ""

        private let paragraphRange: ClosedRange<Int> = 1 ... 10

        var body: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Header
                    ToolHeaderView(
                        iconSystemName: tool.iconSystemName,
                        title: tool.name,
                        subtitle: tool.category.title,
                        description: tool.shortDescription
                    )

                    // Controls
                    controls

                    // Output section - expands naturally with content
                    OutputSection(
                        title: "Generated text",
                        text: output,
                        placeholder:
                            "Lorem ipsum text will appear here. Adjust the options above to change the output.",
                        onCopy: {
                            guard !output.isEmpty else { return }
                            clipboardService.copy(output)
                        }
                    )

                    // Bottom padding
                    Spacer(minLength: 40)
                }
                .padding()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .onAppear {
                if output.isEmpty {
                    regenerateOutput()
                }
            }
            .onChange(of: paragraphCount) { _, _ in
                regenerateOutput()
            }
            .onChange(of: includeClassicOpening) { _, _ in
                regenerateOutput()
            }
        }

        private var controls: some View {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 12) {
                    Stepper(
                        value: $paragraphCount,
                        in: paragraphRange
                    ) {
                        Text("Paragraphs: \(paragraphCount)")
                    }

                    Spacer(minLength: 0)
                }

                Toggle(
                    "Include classic 'Lorem ipsum dolor sit amet' opening",
                    isOn: $includeClassicOpening
                )
            }
        }

        private func regenerateOutput() {
            let configuration = LoremIpsumGenerator.Configuration(
                paragraphCount: paragraphCount,
                includeClassicOpening: includeClassicOpening
            )
            output = LoremIpsumGenerator.generate(configuration: configuration)
        }
    }
}
