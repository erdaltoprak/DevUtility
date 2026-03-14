import SwiftUI

struct OutputPanel<AccessoryContent: View>: View {
    let title: String
    let text: String
    let placeholder: String?
    let onCopy: (() -> Void)?
    @ViewBuilder let accessory: AccessoryContent

    init(
        title: String,
        text: String,
        placeholder: String? = nil,
        onCopy: (() -> Void)? = nil,
        @ViewBuilder accessory: () -> AccessoryContent = { EmptyView() }
    ) {
        self.title = title
        self.text = text
        self.placeholder = placeholder
        self.onCopy = onCopy
        self.accessory = accessory()
    }

    private let panelCornerRadius: CGFloat = 10
    @State private var showCopiedFeedback = false

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

                // Copy button always visible but disabled when empty
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

                accessory
            }

            // Output field with read-only styling
            ZStack(alignment: .topLeading) {
                // Background - subtle gray to indicate read-only
                RoundedRectangle(cornerRadius: panelCornerRadius, style: .continuous)
                    .fill(Color.gray.opacity(0.1))

                ScrollView {
                    if text.isEmpty {
                        if let placeholder {
                            Text(placeholder)
                                .font(.system(.body, design: .monospaced))
                                .foregroundStyle(.secondary.opacity(0.6))
                                .frame(maxWidth: .infinity, alignment: .topLeading)
                                .padding(12)
                        }
                    } else {
                        Text(text)
                            .font(.system(.body, design: .monospaced))
                            .textSelection(.enabled)
                            .frame(maxWidth: .infinity, alignment: .topLeading)
                            .padding(12)
                    }
                }
                .scrollIndicators(.visible)
            }
            .frame(minHeight: 80)
        }
    }
}

#Preview {
    OutputPanel(
        title: "Output",
        text: "Sample output text here...",
        placeholder: "Output will appear here...",
        onCopy: {}
    )
    .padding()
}
