import Foundation

public final class HistoryStore {
    public static let key = "app.captureonedate.history"

    private let defaults: UserDefaults

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    public func load() -> [HistoryBatch] {
        guard let data = defaults.data(forKey: Self.key) else { return [] }
        return (try? JSONDecoder().decode([HistoryBatch].self, from: data)) ?? []
    }

    public func save(_ batches: [HistoryBatch]) {
        if let data = try? JSONEncoder().encode(batches) {
            defaults.set(data, forKey: Self.key)
        }
    }
}
