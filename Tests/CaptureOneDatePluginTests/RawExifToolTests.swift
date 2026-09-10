import XCTest
@testable import CaptureOneDatePlugin

final class RawExifToolTests: XCTestCase {
    override func tearDown() {
        RawExifTool.locateExecutable = RawExifTool.defaultLocate
        super.tearDown()
    }

    func test_isRaw_byExtension() {
        XCTAssertTrue(RawExifTool.isRaw(at: URL(fileURLWithPath: "/a/b.CR3")))
        XCTAssertTrue(RawExifTool.isRaw(at: URL(fileURLWithPath: "/a/b.nef")))
        XCTAssertFalse(RawExifTool.isRaw(at: URL(fileURLWithPath: "/a/b.jpg")))
    }

    func test_writeArguments_includeDateAndOffset() {
        let date = Date(timeIntervalSince1970: 1_700_000_000)
        let tz = TimeZone(secondsFromGMT: 3600)!
        let args = RawExifTool.writeArguments(date: date, timeZone: tz, file: "/tmp/a.cr2")
        XCTAssertTrue(args.contains("-overwrite_original"))
        XCTAssertTrue(args.contains(where: { $0.hasPrefix("-DateTimeOriginal=") }))
        XCTAssertTrue(args.contains("-OffsetTimeOriginal=+01:00"))
        XCTAssertEqual(args.last, "/tmp/a.cr2")
    }

    func test_writeCaptureDate_withoutExifTool_throws() {
        RawExifTool.locateExecutable = { nil }
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("c1dp-\(UUID().uuidString).cr2")
        FileManager.default.createFile(atPath: url.path, contents: Data([0x00]), attributes: nil)
        defer { try? FileManager.default.removeItem(at: url) }
        XCTAssertThrowsError(try ExifWriter.writeCaptureDate(Date(), timeZone: .current, at: url)) { err in
            guard case DateOperationError.exifToolMissing = err else {
                return XCTFail("expected exifToolMissing, got \(err)")
            }
        }
    }
}
