import XCTest
import ImageIO
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
}
