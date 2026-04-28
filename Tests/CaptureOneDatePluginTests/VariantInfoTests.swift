import XCTest
@testable import CaptureOneDatePlugin

final class VariantInfoTests: XCTestCase {
    func test_equatable_byPath() {
        let a = VariantInfo(filePath: "/tmp/a.jpg", filename: "a.jpg", currentExifDate: nil)
        let b = VariantInfo(filePath: "/tmp/a.jpg", filename: "a.jpg", currentExifDate: nil)
        XCTAssertEqual(a, b)
    }

    func test_dedupedByPath() {
        let date = Date()
        let a = VariantInfo(filePath: "/tmp/a.jpg", filename: "a.jpg", currentExifDate: nil)
        let b = VariantInfo(filePath: "/tmp/a.jpg", filename: "a.jpg", currentExifDate: date)
        // Same path => treated as same entry by dedup logic; equality compares all fields.
        XCTAssertNotEqual(a, b)
        XCTAssertEqual(a.filePath, b.filePath)
    }
}
