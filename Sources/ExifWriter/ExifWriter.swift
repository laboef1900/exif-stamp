import Foundation
import ImageIO

public enum ExifWriter {
    public static func readCaptureDate(at url: URL) throws -> Date? {
        if let fromImageIO = try? readCaptureDateViaImageIO(at: url) {
            return fromImageIO
        }
        if RawExifTool.isRaw(at: url) {
            return try RawExifTool.readCaptureDate(at: url)
        }
        return try readCaptureDateViaImageIO(at: url)
    }

    private static func readCaptureDateViaImageIO(at url: URL) throws -> Date? {
        guard let src = CGImageSourceCreateWithURL(url as CFURL, nil) else {
            throw DateOperationError.couldNotReadImage(path: url.path)
        }
        guard let props = CGImageSourceCopyPropertiesAtIndex(src, 0, nil) as? [CFString: Any] else {
            throw DateOperationError.couldNotReadImage(path: url.path)
        }
        let exif = props[kCGImagePropertyExifDictionary] as? [CFString: Any]
        guard let s = exif?[kCGImagePropertyExifDateTimeOriginal] as? String else { return nil }
        let tz: TimeZone
        if let offset = exif?[kCGImagePropertyExifOffsetTimeOriginal] as? String,
           let parsed = ExifDateFormatter.timeZone(fromOffset: offset) {
            tz = parsed
        } else {
            tz = TimeZone(secondsFromGMT: 0)!
        }
        return ExifDateFormatter.date(from: s, timeZone: tz)
    }

    /// v1.0-compatible overload — defaults TZ to the system's current zone so
    /// callers that haven't migrated to the TZ-aware overload still get
    /// OffsetTimeOriginal / OffsetTimeDigitized written, matching the v1.1 spec.
    public static func writeCaptureDate(_ date: Date, at url: URL) throws {
        try writeCaptureDate(date, timeZone: .current, at: url)
    }

    /// v1.1 TZ-aware overload. When `timeZone` is non-nil, also writes
    /// OffsetTimeOriginal + OffsetTimeDigitized formatted as `±HH:MM` for the
    /// given target date (so DST is correctly resolved).
    public static func writeCaptureDate(_ date: Date, timeZone: TimeZone?, at url: URL) throws {
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw DateOperationError.fileNotFound(path: url.path)
        }
        let tz = timeZone ?? .current
        if RawExifTool.isRaw(at: url) {
            try RawExifTool.writeCaptureDate(date, timeZone: tz, at: url)
            return
        }
        guard let src = CGImageSourceCreateWithURL(url as CFURL, nil) else {
            throw DateOperationError.couldNotReadImage(path: url.path)
        }
        guard let typeId = CGImageSourceGetType(src) else {
            throw DateOperationError.couldNotReadImage(path: url.path)
        }

        if (typeId as String) == "public.jpeg" {
            try JPEGExifPatch.writeCaptureDate(date, timeZone: tz, at: url)
            return
        }

        let writableTypes = (CGImageDestinationCopyTypeIdentifiers() as? [String]) ?? []
        guard writableTypes.contains(typeId as String) else {
            throw DateOperationError.formatNotSupported(path: url.path)
        }

        let formatted = ExifDateFormatter.string(from: date, timeZone: tz)
        let offset = formatOffset(tz, for: date)

        let existingProps = CGImageSourceCopyPropertiesAtIndex(src, 0, nil) as? [CFString: Any] ?? [:]
        var exif = (existingProps[kCGImagePropertyExifDictionary] as? [CFString: Any]) ?? [:]
        exif[kCGImagePropertyExifDateTimeOriginal] = formatted
        exif[kCGImagePropertyExifDateTimeDigitized] = formatted
        exif[kCGImagePropertyExifOffsetTimeOriginal] = offset
        exif[kCGImagePropertyExifOffsetTimeDigitized] = offset
        var tiff = (existingProps[kCGImagePropertyTIFFDictionary] as? [CFString: Any]) ?? [:]
        tiff[kCGImagePropertyTIFFDateTime] = formatted

        let mergedProps: [CFString: Any] = [
            kCGImagePropertyExifDictionary: exif,
            kCGImagePropertyTIFFDictionary: tiff,
        ]

        let tempURL = url.deletingLastPathComponent()
            .appendingPathComponent(".c1dp-\(UUID().uuidString).tmp")
        guard let dest = CGImageDestinationCreateWithURL(tempURL as CFURL, typeId, 1, nil) else {
            throw DateOperationError.fileNotWritable(path: url.path)
        }
        CGImageDestinationAddImageFromSource(dest, src, 0, mergedProps as CFDictionary)
        guard CGImageDestinationFinalize(dest) else {
            try? FileManager.default.removeItem(at: tempURL)
            throw DateOperationError.writeFailed(path: url.path, underlying: "CGImageDestinationFinalize returned false")
        }
        guard let verify = CGImageSourceCreateWithURL(tempURL as CFURL, nil),
              CGImageSourceGetStatus(verify) == .statusComplete else {
            try? FileManager.default.removeItem(at: tempURL)
            throw DateOperationError.writeFailed(path: url.path, underlying: "Output image failed integrity check")
        }
        do {
            _ = try FileManager.default.replaceItemAt(url, withItemAt: tempURL)
        } catch {
            try? FileManager.default.removeItem(at: tempURL)
            throw DateOperationError.writeFailed(path: url.path, underlying: error.localizedDescription)
        }
    }

    /// Formats a TimeZone offset for the given date as ±HH:MM (e.g. "+02:00", "-05:30").
    static func formatOffset(_ tz: TimeZone, for date: Date) -> String {
        let totalSeconds = tz.secondsFromGMT(for: date)
        let sign = totalSeconds >= 0 ? "+" : "-"
        let abs = Swift.abs(totalSeconds)
        return String(format: "%@%02d:%02d", sign, abs / 3600, (abs % 3600) / 60)
    }
}
