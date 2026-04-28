import XCTest
@testable import CaptureOneDatePlugin

final class VariantInfoTests: XCTestCase {
    func test_equatable_byPath() {
        let a = VariantInfo(filePath: "/tmp/a.jpg", filename: "a.jpg", currentExifDate: nil)
        let b = VariantInfo(filePath: "/tmp/a.jpg", filename: "a.jpg", currentExifDate: nil)
        XCTAssertEqual(a, b)
    }

    func test_samePathDifferentDate_notEqual() {
        let date = Date()
        let a = VariantInfo(filePath: "/tmp/a.jpg", filename: "a.jpg", currentExifDate: nil)
        let b = VariantInfo(filePath: "/tmp/a.jpg", filename: "a.jpg", currentExifDate: date)
        XCTAssertNotEqual(a, b)
    }

    func test_dedupedInSet_bySameId() {
        let a = VariantInfo(filePath: "/tmp/a.jpg", filename: "a.jpg", currentExifDate: nil)
        let b = VariantInfo(filePath: "/tmp/a.jpg", filename: "a.jpg", currentExifDate: nil)
        XCTAssertEqual(Set([a, b]).count, 1)
    }
}
