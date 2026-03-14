import SwiftUI

#if os(macOS)
    import AppKit
#endif

#if os(macOS)
    private final class AppDelegate: NSObject, NSApplicationDelegate {
        func applicationDidFinishLaunching(_ notification: Notification) {
            NSWindow.allowsAutomaticWindowTabbing = false
        }
    }
#endif

@main
struct DevUtilityApp: App {
    #if os(macOS)
        @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    #endif

    @State private var settings = SettingsStore()
    @State private var clipboardService = ClipboardService()
    #if os(macOS)
        @State private var columnVisibility: NavigationSplitViewVisibility = .all
    #endif

    private var contentView: some View {
        #if os(macOS)
            ContentView(columnVisibility: $columnVisibility)
        #else
            ContentView()
        #endif
    }

    var body: some Scene {
        WindowGroup {
            contentView
                .environment(settings)
                .environment(settings.theme)
                .environment(clipboardService)
                .tint(settings.theme.accentColor)
                .preferredColorScheme(settings.theme.resolvedColorScheme)
        }
        #if os(macOS)
            .commands {
                CommandGroup(replacing: .sidebar) {
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            columnVisibility = columnVisibility == .detailOnly ? .all : .detailOnly
                        }
                    } label: {
                        Label(
                            columnVisibility == .detailOnly ? "Show Sidebar" : "Hide Sidebar",
                            systemImage: "sidebar.leading"
                        )
                    }
                    .keyboardShortcut("S", modifiers: [.command, .control])
                }
            }
        #endif
        #if os(macOS)
            Settings {
                NavigationStack {
                    ContentView.SettingsView()
                }
                .environment(settings)
                .environment(settings.theme)
                .environment(clipboardService)
                .tint(settings.theme.accentColor)
            }
        #endif
    }
}
