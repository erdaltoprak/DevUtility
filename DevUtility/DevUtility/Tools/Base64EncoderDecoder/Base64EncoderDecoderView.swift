import SwiftUI

extension ContentView {
    struct Base64EncoderDecoderView: View {
        let tool: Tool

        @Environment(ClipboardService.self) private var clipboardService
        #if os(iOS)
            @Environment(\.horizontalSizeClass) private var horizontalSizeClass
        #endif

        @State private var input = ""
        @State private var mode: Base64EncoderDecoder.Mode = .encode
        @State private var output = ""
        @State private var errorMessage: String?

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

                    // Mode picker
                    modePicker

                    // Input section
                    inputPanel

                    // Validation message
                    validationMessage

                    // Output section - expands naturally
                    OutputSection(
                        title: "Output",
                        text: output,
                        placeholder: mode == .encode
                            ? "Base64‑encoded text will appear here."
                            : "Decoded text will appear here.",
                        onCopy: {
                            if !output.isEmpty {
                                clipboardService.copy(output)
                            }
                        }
                    )

                    // Bottom padding
                    Spacer(minLength: 40)
                }
                .padding()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .onChange(of: input) { _, newValue in
                performConversion(for: newValue)
            }
            .onChange(of: mode) { _, _ in
                performConversion(for: input)
            }
        }

        private var modePicker: some View {
            HStack(spacing: 12) {
                Image(systemName: "arrow.left.arrow.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Picker("Mode", selection: $mode) {
                    ForEach(Base64EncoderDecoder.Mode.allCases) { mode in
                        Text(mode.title)
                            .tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: 200)

                Spacer(minLength: 0)
            }
        }

        private var inputPanel: some View {
            InputPanel(
                title: "Input",
                text: $input,
                prompt: mode == .encode
                    ? "Enter plain text to encode as Base64."
                    : "Enter a Base64 string to decode."
            ) {
                HStack(spacing: 12) {
                    Button {
                        if let clipboardText = clipboardService.readString() {
                            input = clipboardText
                        }
                    } label: {
                        Label("Paste", systemImage: "doc.on.clipboard")
                            .font(.caption)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)

                    Button {
                        input = ""
                    } label: {
                        Label("Clear", systemImage: "xmark.circle")
                            .font(.caption)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                    .tint(.secondary)
                }
            }
        }

        private var validationMessage: some View {
            Group {
                if let errorMessage {
                    HStack(spacing: 6) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.caption)
                            .foregroundStyle(.red)
                        Text(errorMessage)
                            .foregroundStyle(.red)
                            .font(.subheadline)
                        Spacer()
                    }
                    .padding(.horizontal, 4)
                }
            }
        }

        private func performConversion(for value: String) {
            let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)

            guard !trimmed.isEmpty else {
                output = ""
                errorMessage = nil
                return
            }

            do {
                let result = try Base64EncoderDecoder.convert(trimmed, mode: mode)
                output = result
                errorMessage = nil
            } catch let error as Base64EncoderDecoder.ConversionError {
                output = ""
                errorMessage = error.localizedDescription
            } catch {
                output = ""
                errorMessage = "An unexpected error occurred while processing the input."
            }
        }
    }
}
