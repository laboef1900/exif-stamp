import XCTest
import ImageIO
import UniformTypeIdentifiers
@testable import CaptureOneDatePlugin

final class ExifWriterTests: XCTestCase {
    func test_readCaptureDate_returnsNil_forFileWithoutDate() throws {
        let url = try Fixtures.makeJPEG(date: nil)
        defer { try? FileManager.default.removeItem(at: url) }
        XCTAssertNil(try ExifWriter.readCaptureDate(at: url))
    }

    func test_readCaptureDate_returnsDate_forFileWithDate() throws {
        let date = Date(timeIntervalSince1970: 1_700_000_000)
        let url = try Fixtures.makeJPEG(date: date)
        defer { try? FileManager.default.removeItem(at: url) }
        let read = try ExifWriter.readCaptureDate(at: url)
        XCTAssertNotNil(read)
        // Tolerate one-second rounding from the EXIF text encoding.
        XCTAssertLessThan(abs(read!.timeIntervalSince(date)), 1.5)
    }

    func test_readCaptureDate_throwsCouldNotReadImage_forNonImage() {
        let bogus = FileManager.default.temporaryDirectory.appendingPathComponent("not-an-image.jpg")
        try? "garbage".write(to: bogus, atomically: true, encoding: .utf8)
        defer { try? FileManager.default.removeItem(at: bogus) }
        XCTAssertThrowsError(try ExifWriter.readCaptureDate(at: bogus)) { err in
            guard case DateOperationError.couldNotReadImage = err else {
                return XCTFail("Expected couldNotReadImage, got \(err)")
            }
        }
    }

    func test_writeCaptureDate_setsDateOnUndatedJPEG() throws {
        let url = try Fixtures.makeJPEG(date: nil)
        defer { try? FileManager.default.removeItem(at: url) }
        let target = Date(timeIntervalSince1970: 1_700_000_000)
        try ExifWriter.writeCaptureDate(target, at: url)
        let read = try ExifWriter.readCaptureDate(at: url)
        XCTAssertNotNil(read)
        XCTAssertLessThan(abs(read!.timeIntervalSince(target)), 1.5)
    }

    func test_writeCaptureDate_overwritesExistingDate() throws {
        let original = Date(timeIntervalSince1970: 1_500_000_000)
        let url = try Fixtures.makeJPEG(date: original)
        defer { try? FileManager.default.removeItem(at: url) }
        let target = Date(timeIntervalSince1970: 1_700_000_000)
        try ExifWriter.writeCaptureDate(target, at: url)
        let read = try ExifWriter.readCaptureDate(at: url)!
        XCTAssertLessThan(abs(read.timeIntervalSince(target)), 1.5)
    }

    func test_writeCaptureDate_preservesGPS() throws {
        let url = try Fixtures.makeJPEGWithGPS(date: nil, lat: 51.5, lon: -0.12)
        defer { try? FileManager.default.removeItem(at: url) }
        try ExifWriter.writeCaptureDate(Date(timeIntervalSince1970: 1_700_000_000), at: url)

        let src = CGImageSourceCreateWithURL(url as CFURL, nil)!
        let props = CGImageSourceCopyPropertiesAtIndex(src, 0, nil) as? [CFString: Any]
        let gps = props?[kCGImagePropertyGPSDictionary] as? [CFString: Any]
        XCTAssertEqual(gps?[kCGImagePropertyGPSLatitudeRef] as? String, "N")
        XCTAssertEqual((gps?[kCGImagePropertyGPSLatitude] as? Double) ?? 0, 51.5, accuracy: 0.001)
    }

    func test_writeCaptureDate_throwsFileNotFound_forMissingFile() {
        let url = URL(fileURLWithPath: "/tmp/c1dp-does-not-exist-\(UUID().uuidString).jpg")
        XCTAssertThrowsError(try ExifWriter.writeCaptureDate(Date(), at: url)) { err in
            guard case DateOperationError.fileNotFound = err else {
                return XCTFail("Expected fileNotFound, got \(err)")
            }
        }
    }

    func test_writeCaptureDate_TIFF_roundTrip() throws {
        let url = try Fixtures.makeTIFF(date: nil)
        defer { try? FileManager.default.removeItem(at: url) }
        let target = Date(timeIntervalSince1970: 1_700_000_000)
        try ExifWriter.writeCaptureDate(target, at: url)
        let read = try ExifWriter.readCaptureDate(at: url)!
        XCTAssertLessThan(abs(read.timeIntervalSince(target)), 1.5)
    }

    func test_writeCaptureDate_HEIC_roundTrip() throws {
        let url = try Fixtures.makeHEIC(date: nil)
        defer { try? FileManager.default.removeItem(at: url) }
        let target = Date(timeIntervalSince1970: 1_700_000_000)
        try ExifWriter.writeCaptureDate(target, at: url)
        let read = try ExifWriter.readCaptureDate(at: url)!
        XCTAssertLessThan(abs(read.timeIntervalSince(target)), 1.5)
    }

    func test_writeCaptureDate_doesNotChangeJPEGPixels() throws {
        let url = try makeLossyJPEG()
        defer { try? FileManager.default.removeItem(at: url) }
        let before = try XCTUnwrap(pixelDigest(url))
        let sizeBefore = try FileManager.default.attributesOfItem(atPath: url.path)[.size] as? Int ?? 0
        try ExifWriter.writeCaptureDate(Date(timeIntervalSince1970: 1_700_000_000), at: url)
        let after = try XCTUnwrap(pixelDigest(url))
        XCTAssertEqual(before, after, "EXIF write recompressed JPEG pixels")
        let sizeAfter = try FileManager.default.attributesOfItem(atPath: url.path)[.size] as? Int ?? 0
        XCTAssertGreaterThan(sizeAfter, 0)
        XCTAssertLessThan(abs(sizeAfter - sizeBefore), max(sizeBefore / 5, 512))
    }

    private func makeLossyJPEG() throws -> URL {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("c1dp-lossy-\(UUID().uuidString).jpg")
        let width = 64, height = 64
        let cs = CGColorSpaceCreateDeviceRGB()
        let ctx = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8,
                            bytesPerRow: width * 4, space: cs,
                            bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)!
        for x in 0..<width {
            ctx.setFillColor(CGColor(red: CGFloat(x) / CGFloat(width), green: 0.2, blue: 0.7, alpha: 1))
            ctx.fill(CGRect(x: x, y: 0, width: 1, height: height))
        }
        let image = ctx.makeImage()!
        guard let dest = CGImageDestinationCreateWithURL(url as CFURL, UTType.jpeg.identifier as CFString, 1, nil) else {
            throw NSError(domain: "ExifWriterTests", code: 1)
        }
        CGImageDestinationAddImage(dest, image, [kCGImageDestinationLossyCompressionQuality: 0.4] as CFDictionary)
        guard CGImageDestinationFinalize(dest) else {
            throw NSError(domain: "ExifWriterTests", code: 2)
        }
        return url
    }

    private func pixelDigest(_ url: URL) -> String? {
        guard let src = CGImageSourceCreateWithURL(url as CFURL, nil),
              let img = CGImageSourceCreateImageAtIndex(src, 0, [kCGImageSourceShouldCache: false] as CFDictionary)
        else { return nil }
        let width = img.width, height = img.height
        var data = [UInt8](repeating: 0, count: width * height * 4)
        let cs = CGColorSpaceCreateDeviceRGB()
        guard let ctx = CGContext(data: &data, width: width, height: height, bitsPerComponent: 8,
                                  bytesPerRow: width * 4, space: cs,
                                  bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { return nil }
        ctx.draw(img, in: CGRect(x: 0, y: 0, width: width, height: height))
        return data.map { String(format: "%02x", $0) }.joined()
    }
}
