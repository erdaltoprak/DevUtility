import Observation
import SwiftUI

@MainActor
@Observable
final class AppTheme {
    enum ColorSchemePreference: String, CaseIterable, Identifiable {
        case system
        case light
        case dark

        var id: String { rawValue }

        var title: String {
            switch self {
            case .system:
                "System"
            case .light:
                "Light"
            case .dark:
                "Dark"
            }
        }

        var colorScheme: ColorScheme? {
            switch self {
            case .system:
                nil
            case .light:
                .light
            case .dark:
                .dark
            }
        }
    }

    var colorSchemePreference: ColorSchemePreference = .system
    var accentColor: Color = .accentColor

    var resolvedColorScheme: ColorScheme? {
        colorSchemePreference.colorScheme
    }
}
