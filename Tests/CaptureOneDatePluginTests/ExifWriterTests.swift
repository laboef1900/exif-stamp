import XCTest
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
}
