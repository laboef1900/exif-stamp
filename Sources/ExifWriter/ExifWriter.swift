import Foundation
import ImageIO

public enum ExifWriter {
    public static func readCaptureDate(at url: URL) throws -> Date? {
        guard let src = CGImageSourceCreateWithURL(url as CFURL, nil) else {
            throw DateOperationError.couldNotReadImage(path: url.path)
        }
        guard let props = CGImageSourceCopyPropertiesAtIndex(src, 0, nil) as? [CFString: Any] else {
            throw DateOperationError.couldNotReadImage(path: url.path)
        }
        let exif = props[kCGImagePropertyExifDictionary] as? [CFString: Any]
        if let s = exif?[kCGImagePropertyExifDateTimeOriginal] as? String,
           let d = ExifDateFormatter.utc.date(from: s) {
            return d
        }
        return nil
    }

    public static func writeCaptureDate(_ date: Date, at url: URL) throws {
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw DateOperationError.fileNotFound(path: url.path)
        }
        guard let src = CGImageSourceCreateWithURL(url as CFURL, nil) else {
            throw DateOperationError.couldNotReadImage(path: url.path)
        }
        guard let typeId = CGImageSourceGetType(src) else {
            throw DateOperationError.couldNotReadImage(path: url.path)
        }

        // ImageIO can read many formats it can't write (e.g., proprietary RAW). Pre-check
        // so the user gets a meaningful error rather than a "write failed" surprise.
        let writableTypes = (CGImageDestinationCopyTypeIdentifiers() as? [String]) ?? []
        guard writableTypes.contains(typeId as String) else {
            throw DateOperationError.formatNotSupported(path: url.path)
        }

        let formatted = ExifDateFormatter.utc.string(from: date)

        // CGImageDestinationAddImageFromSource overrides at the top-level key, which
        // would drop other EXIF/TIFF tags. Read the existing sub-dicts and merge.
        let existingProps = CGImageSourceCopyPropertiesAtIndex(src, 0, nil) as? [CFString: Any] ?? [:]
        var exif = (existingProps[kCGImagePropertyExifDictionary] as? [CFString: Any]) ?? [:]
        exif[kCGImagePropertyExifDateTimeOriginal] = formatted
        exif[kCGImagePropertyExifDateTimeDigitized] = formatted
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

        // CGImageDestinationAddImageFromSource returns Void, so a silent failure
        // (e.g. truncated source ImageIO opened but couldn't decode at pixel level)
        // would otherwise let us replace a valid original with a corrupt file.
        // Re-open the temp and confirm it is a complete image before swapping.
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
}
