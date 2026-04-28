import Foundation

/// Applies a default strategy across a row collection, honouring per-row overrides
/// and manual edits. Pure: takes input rows + defaults, returns updated rows.
public enum AutoFillEngine {

    public static func apply(default defaultStrategy: AutoFillStrategy,
                             defaultTimeZone: TimeZone,
                             to variants: [EditableVariant]) -> [EditableVariant] {
        variants.enumerated().map { index, v in
            // Manual edits stick.
            if v.manuallyEdited { return v }

            // Resolve which strategy applies to this row.
            let strategy = v.strategyOverride ?? defaultStrategy
            let tz = v.timeZoneOverride ?? defaultTimeZone

            var copy = v
            copy.targetDate = computeTarget(strategy: strategy, info: v.info, index: index, timeZone: tz)
            return copy
        }
    }

    private static func computeTarget(strategy: AutoFillStrategy,
                                      info: VariantInfo,
                                      index: Int,
                                      timeZone: TimeZone) -> Date? {
        switch strategy {
        case .sameDate(let d):
            return d
        case .fromFilename(let cfg):
            return FilenameDateParser.parse(info.filename, config: cfg, referenceTimeZone: timeZone)
        case .sequential(let start, let interval):
            return SequentialOrdering.target(at: index, start: start, interval: interval)
        case .shiftBy(let delta):
            return ShiftFiller.target(for: info, delta: delta)
        }
    }
}
