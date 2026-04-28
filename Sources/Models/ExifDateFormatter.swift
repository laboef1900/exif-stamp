import Foundation

/// Single source of truth for the EXIF DateTimeOriginal text encoding.
/// Both production code (ExifWriter) and tests (Fixtures) format dates
/// through this formatter, so a change in one can never silently
/// invalidate the other.
enum ExifDateFormatter {
    static let utc: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy:MM:dd HH:mm:ss"
        f.timeZone = TimeZone(secondsFromGMT: 0)
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()
}
