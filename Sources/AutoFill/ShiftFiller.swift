import Foundation

/// Adds a (signed) Δ to a row's existing EXIF date. Returns nil if the row
/// has no existing date (gracefully skipped on Apply).
public enum ShiftFiller {
    public static func target(for info: VariantInfo, delta: TimeInterval) -> Date? {
        guard let existing = info.currentExifDate else { return nil }
        return existing.addingTimeInterval(delta)
    }
}
