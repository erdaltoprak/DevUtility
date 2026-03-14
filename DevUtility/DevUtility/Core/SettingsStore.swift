import Foundation
import Observation

@MainActor
@Observable
final class SettingsStore {
    struct RecentTool: Identifiable, Codable, Hashable {
        let id: String
        var lastUsedAt: Date
        var useCount: Int
    }

    private enum StorageKeys {
        static let recentTools = "devutility.settings.recentTools"
    }

    let theme: AppTheme

    private(set) var recentTools: [RecentTool] = []

    @ObservationIgnored
    private let userDefaults: UserDefaults

    private let maxRecentTools = 10

    init(userDefaults: UserDefaults = .standard) {
        self.theme = AppTheme()
        self.userDefaults = userDefaults
        loadRecentTools()
    }

    func markToolUsed(id: String) {
        let now = Date()

        if let existingIndex = recentTools.firstIndex(where: { $0.id == id }) {
            var existing = recentTools[existingIndex]
            existing.lastUsedAt = now
            existing.useCount += 1
            recentTools.remove(at: existingIndex)
            recentTools.insert(existing, at: 0)
        } else {
            let entry = RecentTool(id: id, lastUsedAt: now, useCount: 1)
            recentTools.insert(entry, at: 0)
        }

        if recentTools.count > maxRecentTools {
            recentTools.removeLast(recentTools.count - maxRecentTools)
        }

        persistRecentTools()
    }

    func clearRecentTools() {
        recentTools.removeAll()
        userDefaults.removeObject(forKey: StorageKeys.recentTools)
    }

    private func loadRecentTools() {
        guard let data = userDefaults.data(forKey: StorageKeys.recentTools) else {
            return
        }

        do {
            let decoded = try JSONDecoder().decode([RecentTool].self, from: data)
            recentTools = decoded
        } catch {
            recentTools = []
        }
    }

    private func persistRecentTools() {
        do {
            let data = try JSONEncoder().encode(recentTools)
            userDefaults.set(data, forKey: StorageKeys.recentTools)
        } catch {
            // If persistence fails, we keep the in‑memory list and continue.
        }
    }
}
