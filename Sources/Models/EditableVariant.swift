import Foundation

/// One row in the v1.1 editable target-date table.
/// Wraps a v1.0 VariantInfo with per-row state — target, lock, optional strategy/TZ overrides.
public struct EditableVariant: Identifiable, Equatable {
    public let info: VariantInfo
    public var targetDate: Date?
    public var manuallyEdited: Bool
    public var strategyOverride: AutoFillStrategy?
    public var timeZoneOverride: TimeZone?

    public init(info: VariantInfo,
                targetDate: Date? = nil,
                manuallyEdited: Bool = false,
                strategyOverride: AutoFillStrategy? = nil,
                timeZoneOverride: TimeZone? = nil) {
        self.info = info
        self.targetDate = targetDate
        self.manuallyEdited = manuallyEdited
        self.strategyOverride = strategyOverride
        self.timeZoneOverride = timeZoneOverride
    }

    public var id: String { info.filePath }
}

