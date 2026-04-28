import Foundation
import ImageIO
import CoreGraphics
import UniformTypeIdentifiers
@testable import CaptureOneDatePlugin

/// Generates throwaway image files in NSTemporaryDirectory for tests.
/// Callers own the returned URL: use `defer { try? FileManager.default.removeItem(at: url) }`.
enum Fixtures {
    static func makeJPEG(date: Date?) throws -> URL {
        try makeImage(type: UTType.jpeg, date: date, ext: "jpg")
    }

    static func makeTIFF(date: Date?) throws -> URL {
        try makeImage(type: UTType.tiff, date: date, ext: "tif")
    }

    static func makeHEIC(date: Date?) throws -> URL {
        try makeImage(type: UTType.heic, date: date, ext: "heic")
    }

    static func makeJPEGWithGPS(date: Date?, lat: Double, lon: Double) throws -> URL {
        let url = uniqueTempURL(ext: "jpg")
        let cgImage = makeOnePixelImage()
        guard let dest = CGImageDestinationCreateWithURL(url as CFURL, UTType.jpeg.identifier as CFString, 1, nil) else {
            throw NSError(domain: "Fixtures", code: 2,
                          userInfo: [NSLocalizedDescriptionKey: "Could not create JPEG destination at \(url.path)"])
        }
        var props: [CFString: Any] = [
            kCGImagePropertyGPSDictionary: [
                kCGImagePropertyGPSLatitude: abs(lat),
                kCGImagePropertyGPSLatitudeRef: lat >= 0 ? "N" : "S",
                kCGImagePropertyGPSLongitude: abs(lon),
                kCGImagePropertyGPSLongitudeRef: lon >= 0 ? "E" : "W",
            ] as CFDictionary
        ]
        if let date {
            props[kCGImagePropertyExifDictionary] = [
                kCGImagePropertyExifDateTimeOriginal: ExifDateFormatter.utc.string(from: date)
            ] as CFDictionary
        }
        CGImageDestinationAddImage(dest, cgImage, props as CFDictionary)
        guard CGImageDestinationFinalize(dest) else {
            throw NSError(domain: "Fixtures", code: 1)
        }
        return url
    }

    private static func makeImage(type: UTType, date: Date?, ext: String) throws -> URL {
        let url = uniqueTempURL(ext: ext)
        let cgImage = makeOnePixelImage()
        guard let dest = CGImageDestinationCreateWithURL(url as CFURL, type.identifier as CFString, 1, nil) else {
            throw NSError(domain: "Fixtures", code: 2,
                          userInfo: [NSLocalizedDescriptionKey: "Could not create \(type.identifier) destination at \(url.path)"])
        }
        var props: [CFString: Any] = [:]
        if let date {
            props[kCGImagePropertyExifDictionary] = [
                kCGImagePropertyExifDateTimeOriginal: ExifDateFormatter.utc.string(from: date),
                kCGImagePropertyExifDateTimeDigitized: ExifDateFormatter.utc.string(from: date),
            ] as CFDictionary
            props[kCGImagePropertyTIFFDictionary] = [
                kCGImagePropertyTIFFDateTime: ExifDateFormatter.utc.string(from: date)
            ] as CFDictionary
        }
        CGImageDestinationAddImage(dest, cgImage, props as CFDictionary)
        guard CGImageDestinationFinalize(dest) else {
            throw NSError(domain: "Fixtures", code: 1)
        }
        return url
    }

    private static func uniqueTempURL(ext: String) -> URL {
        FileManager.default.temporaryDirectory
            .appendingPathComponent("c1dp-\(UUID().uuidString)")
            .appendingPathExtension(ext)
    }

    private static func makeOnePixelImage() -> CGImage {
        let cs = CGColorSpaceCreateDeviceRGB()
        let ctx = CGContext(data: nil, width: 1, height: 1, bitsPerComponent: 8,
                            bytesPerRow: 4, space: cs,
                            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
        ctx.setFillColor(CGColor(red: 1, green: 0, blue: 0, alpha: 1))
        ctx.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        return ctx.makeImage()!
    }
}
