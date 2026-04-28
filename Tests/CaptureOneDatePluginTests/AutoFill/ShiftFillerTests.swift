import XCTest
@testable import CaptureOneDatePlugin

final class ShiftFillerTests: XCTestCase {
    private let info1 = VariantInfo(filePath: "/a.jpg", filename: "a.jpg",
                                    currentExifDate: Date(timeIntervalSince1970: 1_700_000_000))
    private let info2 = VariantInfo(filePath: "/b.jpg", filename: "b.jpg", currentExifDate: nil)

    func test_appliesPositiveShift() {
        let result = ShiftFiller.target(for: info1, delta: 3600)
        XCTAssertEqual(result, Date(timeIntervalSince1970: 1_700_003_600))
    }

    func test_appliesNegativeShift() {
        let result = ShiftFiller.target(for: info1, delta: -3600)
        XCTAssertEqual(result, Date(timeIntervalSince1970: 1_699_996_400))
    }

    func test_returnsNilForRowWithNoExistingDate() {
        XCTAssertNil(ShiftFiller.target(for: info2, delta: 3600))
    }

    func test_zeroDelta_returnsOriginalDate() {
        XCTAssertEqual(ShiftFiller.target(for: info1, delta: 0), info1.currentExifDate)
    }
}
