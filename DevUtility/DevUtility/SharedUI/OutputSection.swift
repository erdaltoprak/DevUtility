import SwiftUI

struct OutputSection: View {
    let title: String
    let text: String
    let placeholder: String?
    let onCopy: (() -> Void)?

    @State private var showCopiedFeedback = false

    init(
        title: String,
        text: String,
        placeholder: String? = nil,
        onCopy: (() -> Void)? = nil
    ) {
        self.title = title
        self.text = text
        self.placeholder = placeholder
        self.onCopy = onCopy
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Header with title and copy button
            HStack(spacing: 12) {
                HStack(spacing: 6) {
                    Image(systemName: "doc.text")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                }

                Spacer(minLength: 0)

                // Copy button with feedback
                if !text.isEmpty {
                    Button {
                        onCopy?()
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showCopiedFeedback = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                showCopiedFeedback = false
                            }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            if showCopiedFeedback {
                                Image(systemName: "checkmark")
                                    .font(.caption2)
                                Text("Copied!")
                                    .font(.caption)
                            } else {
                                Image(systemName: "doc.on.doc")
                                    .font(.caption)
                                Text("Copy")
                                    .font(.caption)
                            }
                        }
                        .foregroundStyle(Color.accentColor)
                    }
                    .buttonStyle(.plain)
                }
            }

            // Content area - expands naturally with content
            if text.isEmpty {
                if let placeholder {
                    Text(placeholder)
                        .font(.system(.body, design: .monospaced))
                        .foregroundStyle(.secondary.opacity(0.6))
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                        .padding(16)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                }
            } else {
                Text(text)
                    .font(.system(.body, design: .monospaced))
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    .padding(16)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        OutputSection(
            title: "Output",
            text: "Sample output text that can grow...",
            placeholder: "Output will appear here...",
            onCopy: {}
        )

        OutputSection(
            title: "Empty Output",
            text: "",
            placeholder: "No content yet...",
            onCopy: {}
        )
    }
    .padding()
}
