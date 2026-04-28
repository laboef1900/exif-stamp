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

    func test_execute_callsExifAndFSWriters_andReloader() throws {
        let v = VariantInfo(filePath: "/a.jpg", filename: "a.jpg", currentExifDate: nil)
        var exifCalls: [(Date, URL)] = []
        var fsCalls: [(Date, URL)] = []
        var reloadCalls: [[String]] = []

        let op = DateOperation(bridge: MockCaptureOneBridge(),
            exifWriter: { d, u in exifCalls.append((d, u)) },
            exifReader: { _ in nil },
            fsWriter:   { d, u in fsCalls.append((d, u)) },
            reloader:   { p in reloadCalls.append(p) })

        let target = Date(timeIntervalSince1970: 1_700_000_000)
        let results = op.execute(variants: [v], date: target, overwritePolicy: .skipExisting)

        XCTAssertEqual(results.count, 1)
        XCTAssertTrue(results.first!.isSuccess)
        XCTAssertEqual(exifCalls.count, 1)
        XCTAssertEqual(fsCalls.count, 1)
        XCTAssertEqual(reloadCalls, [["/a.jpg"]])
    }

    func test_execute_skipExisting_doesNotTouchDatedFiles() {
        let undated = VariantInfo(filePath: "/a.jpg", filename: "a.jpg", currentExifDate: nil)
        let dated = VariantInfo(filePath: "/b.jpg", filename: "b.jpg", currentExifDate: Date(timeIntervalSince1970: 1))
        var exifCalls: [URL] = []
        let op = DateOperation(bridge: MockCaptureOneBridge(),
            exifWriter: { _, u in exifCalls.append(u) },
            exifReader: { _ in nil },
            fsWriter:   { _, _ in },
            reloader:   { _ in })

        let results = op.execute(variants: [undated, dated], date: Date(), overwritePolicy: .skipExisting)
        XCTAssertEqual(exifCalls.map(\.path), ["/a.jpg"])
        XCTAssertEqual(results.count, 1)
    }

    func test_execute_overwriteAll_writesBothDatedAndUndated() {
        let undated = VariantInfo(filePath: "/a.jpg", filename: "a.jpg", currentExifDate: nil)
        let dated = VariantInfo(filePath: "/b.jpg", filename: "b.jpg", currentExifDate: Date(timeIntervalSince1970: 1))
        var exifCalls: [URL] = []
        let op = DateOperation(bridge: MockCaptureOneBridge(),
            exifWriter: { _, u in exifCalls.append(u) },
            exifReader: { _ in nil },
            fsWriter:   { _, _ in },
            reloader:   { _ in })

        let results = op.execute(variants: [undated, dated], date: Date(), overwritePolicy: .overwriteAll)
        XCTAssertEqual(Set(exifCalls.map(\.path)), Set(["/a.jpg", "/b.jpg"]))
        XCTAssertEqual(results.count, 2)
    }

    func test_execute_perFileErrorDoesNotAbortBatch() {
        let v1 = VariantInfo(filePath: "/a.jpg", filename: "a.jpg", currentExifDate: nil)
        let v2 = VariantInfo(filePath: "/b.jpg", filename: "b.jpg", currentExifDate: nil)
        let op = DateOperation(bridge: MockCaptureOneBridge(),
            exifWriter: { _, u in
                if u.path == "/a.jpg" { throw DateOperationError.fileNotWritable(path: u.path) }
            },
            exifReader: { _ in nil },
            fsWriter:   { _, _ in },
            reloader:   { _ in })

        let results = op.execute(variants: [v1, v2], date: Date(), overwritePolicy: .skipExisting)
        XCTAssertEqual(results.count, 2)
        XCTAssertFalse(results[0].isSuccess)
        XCTAssertTrue(results[1].isSuccess)
    }

    func test_execute_reloadOnlyForSuccessfulWrites() {
        let v1 = VariantInfo(filePath: "/a.jpg", filename: "a.jpg", currentExifDate: nil)
        let v2 = VariantInfo(filePath: "/b.jpg", filename: "b.jpg", currentExifDate: nil)
        var reloadPaths: [String] = []
        let op = DateOperation(bridge: MockCaptureOneBridge(),
            exifWriter: { _, u in
                if u.path == "/a.jpg" { throw DateOperationError.fileNotWritable(path: u.path) }
            },
            exifReader: { _ in nil },
            fsWriter:   { _, _ in },
            reloader:   { p in reloadPaths = p })

        _ = op.execute(variants: [v1, v2], date: Date(), overwritePolicy: .skipExisting)
        XCTAssertEqual(reloadPaths, ["/b.jpg"])
    }
}
