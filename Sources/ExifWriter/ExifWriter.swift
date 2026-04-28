import Foundation
import ImageIO

public enum ExifWriter {
    private static let exifFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy:MM:dd HH:mm:ss"
        f.timeZone = TimeZone(secondsFromGMT: 0)
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()

    public static func readCaptureDate(at url: URL) throws -> Date? {
        guard let src = CGImageSourceCreateWithURL(url as CFURL, nil) else {
            throw DateOperationError.couldNotReadImage(path: url.path)
        }
        guard let props = CGImageSourceCopyPropertiesAtIndex(src, 0, nil) as? [CFString: Any] else {
            throw DateOperationError.couldNotReadImage(path: url.path)
        }
        let exif = props[kCGImagePropertyExifDictionary] as? [CFString: Any]
        if let s = exif?[kCGImagePropertyExifDateTimeOriginal] as? String,
           let d = exifFormatter.date(from: s) {
            return d
        }
        return nil
    }
}
