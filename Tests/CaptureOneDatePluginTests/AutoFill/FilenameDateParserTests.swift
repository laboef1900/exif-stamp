import XCTest
@testable import CaptureOneDatePlugin

final class FilenameDateParserTests: XCTestCase {
    private let utc = TimeZone(secondsFromGMT: 0)!

    private func components(_ d: Date) -> DateComponents {
        var cal = Calendar(identifier: .gregorian); cal.timeZone = utc
        return cal.dateComponents([.year, .month, .day, .hour, .minute, .second], from: d)
    }

    func test_camera_IMG_pattern() throws {
        let date = try XCTUnwrap(FilenameDateParser.parse("IMG_20210315_142030.jpg", config: .init(), referenceTimeZone: utc))
        let c = components(date)
        XCTAssertEqual(c.year, 2021); XCTAssertEqual(c.month, 3); XCTAssertEqual(c.day, 15)
        XCTAssertEqual(c.hour, 14); XCTAssertEqual(c.minute, 20); XCTAssertEqual(c.second, 30)
    }

    func test_olderNikon_DSC_pattern() throws {
        let date = try XCTUnwrap(FilenameDateParser.parse("DSC_20180101_000000.jpg", config: .init(), referenceTimeZone: utc))
        let c = components(date)
        XCTAssertEqual(c.year, 2018); XCTAssertEqual(c.month, 1); XCTAssertEqual(c.day, 1)
    }

    func test_whatsapp_IMG_WA_pattern() throws {
        let date = try XCTUnwrap(FilenameDateParser.parse("IMG-20220609-WA0042.jpg", config: .init(), referenceTimeZone: utc))
        let c = components(date)
        XCTAssertEqual(c.year, 2022); XCTAssertEqual(c.month, 6); XCTAssertEqual(c.day, 9)
        XCTAssertEqual(c.hour, 0); XCTAssertEqual(c.minute, 0); XCTAssertEqual(c.second, 0)
    }

    func test_iosPhotos_pattern() throws {
        let date = try XCTUnwrap(FilenameDateParser.parse("2021-03-15 14.20.30.jpg", config: .init(), referenceTimeZone: utc))
        let c = components(date)
        XCTAssertEqual(c.hour, 14); XCTAssertEqual(c.minute, 20); XCTAssertEqual(c.second, 30)
    }

    func test_dateOnly_yyyymmdd_pattern() throws {
        let date = try XCTUnwrap(FilenameDateParser.parse("20210315_scan.jpg", config: .init(), referenceTimeZone: utc))
        let c = components(date)
        XCTAssertEqual(c.year, 2021); XCTAssertEqual(c.hour, 0)
    }

    func test_noMatch_returnsNil() {
        XCTAssertNil(FilenameDateParser.parse("vacation.jpg", config: .init(), referenceTimeZone: utc))
        XCTAssertNil(FilenameDateParser.parse("IMG_001.jpg", config: .init(), referenceTimeZone: utc))
    }

    func test_partialName_camera_pattern() throws {
        // Pattern is anchored "anywhere in the filename"
        let date = try XCTUnwrap(FilenameDateParser.parse("vacation_IMG_20210315_142030_001.jpg", config: .init(), referenceTimeZone: utc))
        let c = components(date)
        XCTAssertEqual(c.year, 2021); XCTAssertEqual(c.day, 15)
    }
}
