import XCTest
@testable import CaptureOneDatePlugin

final class EditableVariantTests: XCTestCase {
    func test_defaultsAreNil() {
        let info = VariantInfo(filePath: "/a.jpg", filename: "a.jpg", currentExifDate: nil)
        let ev = EditableVariant(info: info)
        XCTAssertNil(ev.targetDate)
        XCTAssertFalse(ev.manuallyEdited)
        XCTAssertNil(ev.strategyOverride)
        XCTAssertNil(ev.timeZoneOverride)
        XCTAssertEqual(ev.id, "/a.jpg")
    }

    func test_idIsFilePath() {
        let ev = EditableVariant(info: VariantInfo(filePath: "/x/y.jpg", filename: "y.jpg", currentExifDate: nil))
        XCTAssertEqual(ev.id, "/x/y.jpg")
    }
}
