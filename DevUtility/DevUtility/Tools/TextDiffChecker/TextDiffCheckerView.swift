import SwiftUI

extension ContentView {
    struct TextDiffCheckerView: View {
        let tool: Tool

        @Environment(ClipboardService.self) private var clipboardService
        #if os(iOS)
            @Environment(\.horizontalSizeClass) private var horizontalSizeClass
        #endif

        @State private var originalText = ""
        @State private var modifiedText = ""
        @State private var diffResult: TextDiffResult?
        @State private var showOnlyChanges = false

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

                    // Input panels
                    ViewThatFits(in: .horizontal) {
                        HStack(alignment: .top, spacing: 16) {
                            originalInputPanel
                                .frame(maxWidth: .infinity)
                            modifiedInputPanel
                                .frame(maxWidth: .infinity)
                        }

                        VStack(spacing: 16) {
                            originalInputPanel
                            modifiedInputPanel
                        }
                    }

                    // Diff summary with swap button
                    diffSummary

                    // Diff output - expands naturally
                    diffOutputSection

                    // Bottom padding
                    Spacer(minLength: 40)
                }
                .padding()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .onChange(of: originalText) { _, _ in
                performDiff()
            }
            .onChange(of: modifiedText) { _, _ in
                performDiff()
            }
        }

        private var originalInputPanel: some View {
            InputPanel(
                title: "Input A",
                text: $originalText,
                prompt: "Enter the original text."
            ) {
                HStack(spacing: 12) {
                    Button {
                        if let clipboardText = clipboardService.readString() {
                            originalText = clipboardText
                        }
                    } label: {
                        Label("Paste", systemImage: "doc.on.clipboard")
                            .font(.caption)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)

                    Button {
                        guard !originalText.isEmpty else { return }
                        clipboardService.copy(originalText)
                    } label: {
                        Label("Copy", systemImage: "doc.on.doc")
                            .font(.caption)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                    .disabled(originalText.isEmpty)

                    Button {
                        originalText = ""
                    } label: {
                        Label("Clear", systemImage: "xmark.circle")
                            .font(.caption)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                    .tint(.secondary)
                    .disabled(originalText.isEmpty)
                }
            }
        }

        private var modifiedInputPanel: some View {
            InputPanel(
                title: "Input B",
                text: $modifiedText,
                prompt: "Enter the modified text."
            ) {
                HStack(spacing: 12) {
                    Button {
                        if let clipboardText = clipboardService.readString() {
                            modifiedText = clipboardText
                        }
                    } label: {
                        Label("Paste", systemImage: "doc.on.clipboard")
                            .font(.caption)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)

                    Button {
                        guard !modifiedText.isEmpty else { return }
                        clipboardService.copy(modifiedText)
                    } label: {
                        Label("Copy", systemImage: "doc.on.doc")
                            .font(.caption)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                    .disabled(modifiedText.isEmpty)

                    Button {
                        modifiedText = ""
                    } label: {
                        Label("Clear", systemImage: "xmark.circle")
                            .font(.caption)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                    .tint(.secondary)
                    .disabled(modifiedText.isEmpty)
                }
            }
        }

        private var diffSummary: some View {
            HStack {
                Group {
                    if let diffResult {
                        let changedLineCount = diffResult.rows.reduce(into: 0) { partialResult, row in
                            if row.kind != .unchanged {
                                partialResult += 1
                            }
                        }

                        if diffResult.originalLineCount == 0,
                            diffResult.modifiedLineCount == 0
                        {
                            Text("Enter text above to compare.")
                        } else if diffResult.hasChanges {
                            HStack(spacing: 4) {
                                Image(systemName: "exclamationmark.triangle")
                                    .font(.caption)
                                Text("\(changedLineCount) changed line\(changedLineCount == 1 ? "" : "s")")
                            }
                        } else {
                            HStack(spacing: 4) {
                                Image(systemName: "checkmark.circle")
                                    .font(.caption)
                                Text("No differences — texts are identical")
                            }
                            .foregroundStyle(.green)
                        }
                    } else {
                        Text("Enter text in both panels to see differences.")
                    }
                }
                .foregroundStyle(.secondary)
                .font(.subheadline)

                Spacer()

                // Swap button
                if !originalText.isEmpty || !modifiedText.isEmpty {
                    Button {
                        swapInputs()
                    } label: {
                        Label("Swap", systemImage: "arrow.left.arrow.right")
                            .font(.caption)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
            }
        }

        private var diffOutputSection: some View {
            VStack(alignment: .leading, spacing: 10) {
                // Header with controls
                HStack(spacing: 12) {
                    HStack(spacing: 6) {
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Text("Diff")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }

                    Spacer(minLength: 0)

                    Toggle("Only changes", isOn: $showOnlyChanges)
                        .disabled(diffResult == nil)
                        .font(.caption)

                    // Copy diff button
                    if let diffResult, !diffResult.unifiedDiff.isEmpty {
                        Button {
                            copyDiff()
                        } label: {
                            Label("Copy", systemImage: "doc.on.doc")
                                .font(.caption)
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                    }
                }

                // Diff content - expands naturally
                if let diffResult {
                    VStack(spacing: 0) {
                        ForEach(filteredRows(from: diffResult)) { row in
                            DiffRowView(row: row)
                        }
                    }
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                } else {
                    Text("Differences will appear here after you enter text above.")
                        .foregroundStyle(.secondary.opacity(0.6))
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                        .padding(16)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                }
            }
        }

        private func filteredRows(from result: TextDiffResult) -> [TextDiffRow] {
            if showOnlyChanges {
                return result.rows.filter { row in
                    row.kind != .unchanged
                }
            } else {
                return result.rows
            }
        }

        private func performDiff() {
            let trimmedOriginal = originalText.trimmingCharacters(in: .whitespacesAndNewlines)
            let trimmedModified = modifiedText.trimmingCharacters(in: .whitespacesAndNewlines)

            guard !trimmedOriginal.isEmpty || !trimmedModified.isEmpty else {
                diffResult = nil
                return
            }

            diffResult = TextDiffChecker.diff(
                original: originalText,
                modified: modifiedText
            )
        }

        private func swapInputs() {
            guard !originalText.isEmpty || !modifiedText.isEmpty else { return }
            let temporary = originalText
            originalText = modifiedText
            modifiedText = temporary
        }

        private func copyDiff() {
            guard let unifiedDiff = diffResult?.unifiedDiff,
                !unifiedDiff.isEmpty
            else { return }
            clipboardService.copy(unifiedDiff)
        }
    }

    private struct DiffRowView: View {
        let row: TextDiffRow

        private var backgroundColor: Color {
            switch row.kind {
            case .unchanged:
                .clear
            case .added:
                Color.green.opacity(0.25)
            case .removed:
                Color.red.opacity(0.25)
            }
        }

        var body: some View {
            HStack(spacing: 0) {
                lineColumn(
                    lineNumber: row.originalLineNumber,
                    text: row.originalText
                )

                Divider()

                lineColumn(
                    lineNumber: row.modifiedLineNumber,
                    text: row.modifiedText
                )
            }
            .background(backgroundColor)
        }

        private func lineColumn(
            lineNumber: Int?,
            text: String?
        ) -> some View {
            HStack(spacing: 4) {
                Text(lineNumber.map(String.init) ?? "")
                    .font(.caption2.monospacedDigit())
                    .foregroundStyle(.secondary)
                    .frame(width: 40, alignment: .trailing)

                Text(text ?? "")
                    .font(.system(.body, design: .monospaced))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.vertical, 2)
            .padding(.horizontal, 8)
        }
    }
}
