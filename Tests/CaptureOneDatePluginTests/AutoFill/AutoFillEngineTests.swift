import XCTest
@testable import CaptureOneDatePlugin

final class AutoFillEngineTests: XCTestCase {
    private let utc = TimeZone(secondsFromGMT: 0)!
    private let date = Date(timeIntervalSince1970: 1_700_000_000)

    private func variant(_ path: String, current: Date? = nil, edited: Bool = false,
                         override: AutoFillStrategy? = nil, target: Date? = nil) -> EditableVariant {
        EditableVariant(
            info: VariantInfo(filePath: path, filename: (path as NSString).lastPathComponent, currentExifDate: current),
            targetDate: target, manuallyEdited: edited, strategyOverride: override
        )
    }

    func test_sameDate_fillsAllRows() {
        let v1 = variant("/a.jpg")
        let v2 = variant("/b.jpg")
        let result = AutoFillEngine.apply(default: .sameDate(date), defaultTimeZone: utc, to: [v1, v2])
        XCTAssertEqual(result[0].targetDate, date)
        XCTAssertEqual(result[1].targetDate, date)
    }

    func test_manuallyEdited_isPreserved_onStrategySwitch() {
        let v1 = variant("/a.jpg", edited: true, target: Date(timeIntervalSince1970: 100))
        let v2 = variant("/b.jpg")
        let result = AutoFillEngine.apply(default: .sameDate(date), defaultTimeZone: utc, to: [v1, v2])
        XCTAssertEqual(result[0].targetDate, Date(timeIntervalSince1970: 100))   // sticky
        XCTAssertEqual(result[1].targetDate, date)                                 // recomputed
    }

    func test_rowOverride_takesPrecedence_overDefault() {
        let v1 = variant("/a.jpg", override: .sameDate(Date(timeIntervalSince1970: 50)))
        let v2 = variant("/b.jpg")
        let result = AutoFillEngine.apply(default: .sameDate(date), defaultTimeZone: utc, to: [v1, v2])
        XCTAssertEqual(result[0].targetDate, Date(timeIntervalSince1970: 50))
        XCTAssertEqual(result[1].targetDate, date)
    }

    func test_fromFilename_appliedPerRow() {
        let v1 = variant("/IMG_20210315_142030.jpg")
        let v2 = variant("/no-date.jpg")
        let result = AutoFillEngine.apply(default: .fromFilename(.init()), defaultTimeZone: utc, to: [v1, v2])
        XCTAssertNotNil(result[0].targetDate)
        XCTAssertNil(result[1].targetDate)
    }

    func test_sequential_usesVisualIndex() {
        let v1 = variant("/a.jpg")
        let v2 = variant("/b.jpg")
        let v3 = variant("/c.jpg")
        let result = AutoFillEngine.apply(
            default: .sequential(start: date, interval: 60),
            defaultTimeZone: utc, to: [v1, v2, v3])
        XCTAssertEqual(result[0].targetDate, date)
        XCTAssertEqual(result[1].targetDate, Date(timeIntervalSince1970: 1_700_000_060))
        XCTAssertEqual(result[2].targetDate, Date(timeIntervalSince1970: 1_700_000_120))
    }

    func test_shiftBy_keepsNilForUndatedRows() {
        let v1 = variant("/a.jpg", current: date)
        let v2 = variant("/b.jpg")
        let result = AutoFillEngine.apply(default: .shiftBy(3600), defaultTimeZone: utc, to: [v1, v2])
        XCTAssertEqual(result[0].targetDate, Date(timeIntervalSince1970: 1_700_003_600))
        XCTAssertNil(result[1].targetDate)
    }
}
