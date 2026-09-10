import XCTest
import ImageIO
@testable import CaptureOneDatePlugin

final class ExifWriterTZTests: XCTestCase {

    func test_writesOffsetTimeOriginal_forTokyoTZ() throws {
        let url = try Fixtures.makeJPEG(date: nil)
        defer { try? FileManager.default.removeItem(at: url) }
        let target = Date(timeIntervalSince1970: 1_700_000_000)
        let tokyo = TimeZone(identifier: "Asia/Tokyo")!

        try ExifWriter.writeCaptureDate(target, timeZone: tokyo, at: url)

        let src = CGImageSourceCreateWithURL(url as CFURL, nil)!
        let props = CGImageSourceCopyPropertiesAtIndex(src, 0, nil) as? [CFString: Any]
        let exif = props?[kCGImagePropertyExifDictionary] as? [CFString: Any]
        XCTAssertEqual(exif?[kCGImagePropertyExifOffsetTimeOriginal] as? String, "+09:00")
        XCTAssertEqual(exif?[kCGImagePropertyExifOffsetTimeDigitized] as? String, "+09:00")
        XCTAssertEqual(
            exif?[kCGImagePropertyExifDateTimeOriginal] as? String,
            ExifDateFormatter.string(from: target, timeZone: tokyo))
        let read = try ExifWriter.readCaptureDate(at: url)
        XCTAssertNotNil(read)
        XCTAssertLessThan(abs(read!.timeIntervalSince(target)), 1.5)
    }

    func test_writesOffsetTimeOriginal_forBerlinDST() throws {
        let url = try Fixtures.makeJPEG(date: nil)
        defer { try? FileManager.default.removeItem(at: url) }
        // 2024-06-15 12:00:00 UTC — summer, Berlin = +02:00
        let target = Date(timeIntervalSince1970: 1_718_452_800)
        let berlin = TimeZone(identifier: "Europe/Berlin")!

        try ExifWriter.writeCaptureDate(target, timeZone: berlin, at: url)

        let src = CGImageSourceCreateWithURL(url as CFURL, nil)!
        let props = CGImageSourceCopyPropertiesAtIndex(src, 0, nil) as? [CFString: Any]
        let exif = props?[kCGImagePropertyExifDictionary] as? [CFString: Any]
        XCTAssertEqual(exif?[kCGImagePropertyExifOffsetTimeOriginal] as? String, "+02:00")
        XCTAssertEqual(
            exif?[kCGImagePropertyExifDateTimeOriginal] as? String,
            "2024:06:15 14:00:00")
        let read = try ExifWriter.readCaptureDate(at: url)
        XCTAssertNotNil(read)
        XCTAssertLessThan(abs(read!.timeIntervalSince(target)), 1.5)
    }

    func test_v1_overload_stillWorks_andUsesCurrentTZ() throws {
        let url = try Fixtures.makeJPEG(date: nil)
        defer { try? FileManager.default.removeItem(at: url) }
        let target = Date(timeIntervalSince1970: 1_700_000_000)
        try ExifWriter.writeCaptureDate(target, at: url)
        XCTAssertNotNil(try ExifWriter.readCaptureDate(at: url))
    }

    func test_readCaptureDate_usesOffsetTimeOriginal() throws {
        let url = try Fixtures.makeJPEG(date: nil)
        defer { try? FileManager.default.removeItem(at: url) }
        let tokyo = TimeZone(identifier: "Asia/Tokyo")!
        let target = Date(timeIntervalSince1970: 1_700_000_000)
        try ExifWriter.writeCaptureDate(target, timeZone: tokyo, at: url)
        let read = try XCTUnwrap(ExifWriter.readCaptureDate(at: url))
        XCTAssertLessThan(abs(read.timeIntervalSince(target)), 1.5)
    }

    func test_timeZoneFromOffset_parsesFixedOffsets() {
        XCTAssertEqual(ExifDateFormatter.timeZone(fromOffset: "+09:00")?.secondsFromGMT(), 9 * 3600)
        XCTAssertEqual(ExifDateFormatter.timeZone(fromOffset: "-05:30")?.secondsFromGMT(), -(5 * 3600 + 30 * 60))
        XCTAssertNil(ExifDateFormatter.timeZone(fromOffset: "bogus"))
    }
}
