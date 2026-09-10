import Foundation

/// Single source of truth for the EXIF DateTimeOriginal text encoding.
/// DateTimeOriginal is naive wall-clock; pair it with OffsetTimeOriginal.
enum ExifDateFormatter {
    static let utc: DateFormatter = formatter(timeZone: TimeZone(secondsFromGMT: 0)!)

    static func string(from date: Date, timeZone: TimeZone) -> String {
        formatter(timeZone: timeZone).string(from: date)
    }

    static func date(from string: String, timeZone: TimeZone) -> Date? {
        formatter(timeZone: timeZone).date(from: string)
    }

    /// Parses EXIF OffsetTimeOriginal (`+09:00`, `-05:30`) into a fixed-offset zone.
    static func timeZone(fromOffset offset: String) -> TimeZone? {
        guard offset.count == 6,
              let signChar = offset.first,
              signChar == "+" || signChar == "-",
              offset[offset.index(offset.startIndex, offsetBy: 3)] == ":",
              let hours = Int(offset.dropFirst().prefix(2)),
              let minutes = Int(offset.suffix(2))
        else { return nil }
        let seconds = (hours * 3600 + minutes * 60) * (signChar == "-" ? -1 : 1)
        return TimeZone(secondsFromGMT: seconds)
    }

    private static func formatter(timeZone: TimeZone) -> DateFormatter {
        let f = DateFormatter()
        f.dateFormat = "yyyy:MM:dd HH:mm:ss"
        f.timeZone = timeZone
        f.locale = Locale(identifier: "en_US_POSIX")
        f.isLenient = false
        return f
    }
}
