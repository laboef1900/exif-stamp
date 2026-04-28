import XCTest
@testable import CaptureOneDatePlugin

final class DateOperationTests: XCTestCase {
    func test_preview_splitsByExistingDate() {
        let undated = VariantInfo(filePath: "/a.jpg", filename: "a.jpg", currentExifDate: nil)
        let dated = VariantInfo(filePath: "/b.jpg", filename: "b.jpg", currentExifDate: Date(timeIntervalSince1970: 1_500_000_000))
        let op = DateOperation(bridge: MockCaptureOneBridge(),
                               exifWriter: { _, _ in }, exifReader: { _ in nil },
                               fsWriter: { _, _ in }, reloader: { _ in })
        let plan = op.preview(variants: [undated, dated])
        XCTAssertEqual(plan.toWriteDirectly, [undated])
        XCTAssertEqual(plan.needsOverwriteConfirmation, [dated])
    }

    func test_preview_dedupesByPath() {
        let v1 = VariantInfo(filePath: "/a.jpg", filename: "a.jpg", currentExifDate: nil)
        let v2 = VariantInfo(filePath: "/a.jpg", filename: "a.jpg", currentExifDate: nil)
        let op = DateOperation(bridge: MockCaptureOneBridge(),
                               exifWriter: { _, _ in }, exifReader: { _ in nil },
                               fsWriter: { _, _ in }, reloader: { _ in })
        let plan = op.preview(variants: [v1, v2])
        XCTAssertEqual(plan.toWriteDirectly.count, 1)
    }
}
