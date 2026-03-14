import Observation

#if os(iOS)
    import UIKit
#elseif os(macOS)
    import AppKit
#endif

@MainActor
@Observable
final class ClipboardService {
    func copy(_ string: String) {
        #if os(iOS)
            UIPasteboard.general.string = string
        #elseif os(macOS)
            let pasteboard = NSPasteboard.general
            pasteboard.clearContents()
            pasteboard.setString(string, forType: .string)
        #endif
    }

    func readString() -> String? {
        #if os(iOS)
            UIPasteboard.general.string
        #elseif os(macOS)
            NSPasteboard.general.string(forType: .string)
        #endif
    }
}
