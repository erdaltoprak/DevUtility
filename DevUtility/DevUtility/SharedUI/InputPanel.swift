import SwiftUI

struct InputPanel<AccessoryContent: View>: View {
    let title: String
    let prompt: String?
    @Binding var text: String
    @ViewBuilder let accessory: AccessoryContent

    init(
        title: String,
        text: Binding<String>,
        prompt: String? = nil,
        @ViewBuilder accessory: () -> AccessoryContent = { EmptyView() }
    ) {
        self.title = title
        self._text = text
        self.prompt = prompt
        self.accessory = accessory()
    }

    private let panelCornerRadius: CGFloat = 10

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Header with title and accessory buttons
            HStack(spacing: 12) {
                HStack(spacing: 6) {
                    Image(systemName: "square.and.pencil")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                }

                Spacer(minLength: 0)

                accessory
            }

            // Input field with clear editable styling
            ZStack(alignment: .topLeading) {
                // Background - system background with subtle border to indicate editable
                RoundedRectangle(cornerRadius: panelCornerRadius, style: .continuous)
                    .fill(Color.clear)
                    .background(
                        RoundedRectangle(cornerRadius: panelCornerRadius, style: .continuous)
                            .fill(Color.gray.opacity(0.05))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: panelCornerRadius, style: .continuous)
                            .stroke(Color.accentColor.opacity(0.3), lineWidth: 1.5)
                    )
                    .shadow(color: .black.opacity(0.03), radius: 2, x: 0, y: 1)

                TextEditor(text: $text)
                    .font(.system(.body, design: .monospaced))
                    .padding(10)
                    .scrollIndicators(.visible)
                    .background(Color.clear)

                // Placeholder
                if text.isEmpty, let prompt {
                    Text(prompt)
                        .font(.system(.body, design: .monospaced))
                        .foregroundStyle(.secondary.opacity(0.7))
                        .padding(14)
                        .allowsHitTesting(false)
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var text = ""
    InputPanel(
        title: "Input",
        text: $text,
        prompt: "Enter text here..."
    ) {
        HStack(spacing: 8) {
            Button("Paste") {}
                .font(.caption)
            Button("Clear") {}
                .font(.caption)
        }
    }
    .padding()
}
