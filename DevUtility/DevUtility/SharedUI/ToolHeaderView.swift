import SwiftUI

struct ToolHeaderView: View {
    let iconSystemName: String
    let title: String
    let subtitle: String?
    let description: String?

    init(
        iconSystemName: String,
        title: String,
        subtitle: String? = nil,
        description: String? = nil
    ) {
        self.iconSystemName = iconSystemName
        self.title = title
        self.subtitle = subtitle
        self.description = description
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Icon row
            HStack {
                Image(systemName: iconSystemName)
                    .imageScale(.large)
                    .foregroundStyle(.tint)

                Spacer()
            }

            // Title section - full width, no competing elements
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)

                if let subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            if let description, !description.isEmpty {
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            Divider()
                .padding(.top, 4)
        }
    }
}

#Preview {
    ToolHeaderView(
        iconSystemName: "clock.arrow.2.circlepath",
        title: "Unix Timestamp Converter",
        subtitle: "Converters",
        description: "Convert between Unix timestamps and human-readable dates."
    )
    .padding()
}
