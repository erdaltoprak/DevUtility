import SwiftUI

struct EditorPanel<AccessoryContent: View>: View {
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

    private let panelCornerRadius: CGFloat = 8

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.headline)

                Spacer(minLength: 0)

                accessory
            }

            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: panelCornerRadius, style: .continuous)
                    .strokeBorder(Color.secondary.opacity(0.25))
                    .background(
                        RoundedRectangle(cornerRadius: panelCornerRadius, style: .continuous)
                            .fill(Color.clear)
                    )
                    .clipShape(.rect(cornerRadius: panelCornerRadius))

                TextEditor(text: $text)
                    .font(.system(.body, design: .monospaced))
                    .padding(8)
                    .scrollIndicators(.hidden)
                    .background(Color.clear)
                    .clipShape(.rect(cornerRadius: panelCornerRadius))

                if text.isEmpty, let prompt {
                    Text(prompt)
                        .foregroundStyle(.secondary)
                        .padding(12)
                        .allowsHitTesting(false)
                }
            }
        }
    }
}
