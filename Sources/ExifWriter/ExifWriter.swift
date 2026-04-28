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
}
