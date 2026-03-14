import SwiftUI

extension ContentView {
    struct UnixTimestampConverterView: View {
        let tool: Tool

        @Environment(ClipboardService.self) private var clipboardService

        @State private var input = ""
        @State private var inputMode: UnixTimestampConverter.InputMode = .automatic
        @State private var conversionResult: UnixTimestampConversionResult?
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
                    inputModePicker

                    // Input section
                    inputPanel

                    // Validation message
                    validationMessage

                    // Output section - expands naturally
                    OutputSection(
                        title: "Output",
                        text: formattedResult ?? "",
                        placeholder: "Converted date information will appear here.",
                        onCopy: {
                            if let text = formattedResult, !text.isEmpty {
                                clipboardService.copy(text)
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
            .onChange(of: inputMode) { _, _ in
                performConversion(for: input)
            }
        }

        private var inputModePicker: some View {
            HStack(spacing: 12) {
                Image(systemName: "gear")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Picker("Interpret input", selection: $inputMode) {
                    ForEach(UnixTimestampConverter.InputMode.allCases) { mode in
                        Text(mode.title)
                            .tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: 280)

                Spacer(minLength: 0)
            }
        }

        private var inputPanel: some View {
            InputPanel(
                title: "Input",
                text: $input,
                prompt: "Enter Unix timestamp (seconds or milliseconds) or ISO 8601 date‑time."
            ) {
                HStack(spacing: 12) {
                    Button {
                        setNow()
                    } label: {
                        Label("Now", systemImage: "clock")
                            .font(.caption)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)

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

        private var formattedResult: String? {
            guard let conversionResult else { return nil }

            var lines: [String] = []

            lines.append("Human‑readable")
            lines.append("  Local: \(conversionResult.localDateTime)")
            lines.append("  Relative: \(conversionResult.relativeDescription)")
            lines.append("")

            lines.append("Input")
            lines.append("  Value: \(conversionResult.input)")
            lines.append("  Interpreted as: \(conversionResult.inputKind.description)")
            lines.append("")

            lines.append("Unix")
            lines.append("  Seconds: \(conversionResult.unixSeconds)")
            lines.append("  Milliseconds: \(conversionResult.unixMilliseconds)")
            lines.append("")

            lines.append("Calendar")
            lines.append("  Day of week: \(conversionResult.dayOfWeek)")
            lines.append("  Week of year: \(conversionResult.weekOfYear)")
            lines.append("  Leap year: \(conversionResult.isLeapYear ? "Yes" : "No")")

            return lines.joined(separator: "\n")
        }

        private func setNow() {
            let now = Date()
            let seconds = Int64(now.timeIntervalSince1970.rounded())
            inputMode = .seconds
            input = String(seconds)
        }

        private func performConversion(for value: String) {
            do {
                if value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    conversionResult = nil
                    errorMessage = nil
                    return
                }

                let result = try UnixTimestampConverter.convert(
                    value,
                    mode: inputMode
                )
                conversionResult = result
                errorMessage = nil
            } catch let error as UnixTimestampConversionError {
                conversionResult = nil
                errorMessage = error.localizedDescription
            } catch {
                conversionResult = nil
                errorMessage = "An unexpected error occurred while converting the value."
            }
        }
    }
}
