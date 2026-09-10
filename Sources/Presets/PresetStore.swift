import Foundation

public final class PresetStore {
    public static let presetsKey = "app.captureonedate.presets"
    public static let activeIDKey = "app.captureonedate.activePresetID"

    private let defaults: UserDefaults

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    public func load() -> (presets: [Preset], activeID: UUID?) {
        let active: UUID? = defaults.string(forKey: Self.activeIDKey).flatMap(UUID.init(uuidString:))
        guard let data = defaults.data(forKey: Self.presetsKey) else {
            return ([], active)
        }
        do {
            let presets = try JSONDecoder().decode([Preset].self, from: data)
            return (presets, active)
        } catch {
            return ([], nil)
        }
    }

    public func save(presets: [Preset], activeID: UUID?) {
        if let data = try? JSONEncoder().encode(presets) {
            defaults.set(data, forKey: Self.presetsKey)
        }
        if let activeID {
            defaults.set(activeID.uuidString, forKey: Self.activeIDKey)
        } else {
            defaults.removeObject(forKey: Self.activeIDKey)
        }
    }
}
