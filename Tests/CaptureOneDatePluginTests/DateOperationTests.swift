import XCTest
@testable import CaptureOneDatePlugin

final class DateOperationTests: XCTestCase {
    private let utc = TimeZone(secondsFromGMT: 0)!

    private func ev(_ path: String, target: Date?, current: Date? = nil) -> EditableVariant {
        EditableVariant(
            info: VariantInfo(filePath: path, filename: (path as NSString).lastPathComponent, currentExifDate: current),
            targetDate: target
        )
    }

    func test_execute_writesEachRowsTargetDate() {
        let target1 = Date(timeIntervalSince1970: 100)
        let target2 = Date(timeIntervalSince1970: 200)
        var exifCalls: [(Date, URL, TimeZone)] = []
        var fsCalls: [(Date, URL)] = []
        var reloadCalls: [[String]] = []

        let op = DateOperation(bridge: MockCaptureOneBridge(),
            exifWriter: { d, tz, u in exifCalls.append((d, u, tz)) },
            exifReader: { _ in nil },
            fsWriter:   { d, u in fsCalls.append((d, u)) },
            reloader:   { p in reloadCalls.append(p) })

        let results = op.execute(
            variants: [ev("/a.jpg", target: target1), ev("/b.jpg", target: target2)],
            defaultTimeZone: utc,
            overwritePolicy: .skipExisting)

        XCTAssertEqual(results.count, 2)
        XCTAssertEqual(exifCalls.count, 2)
        XCTAssertEqual(fsCalls.count, 2)
        XCTAssertEqual(Set(reloadCalls.flatMap { $0 }), Set(["/a.jpg", "/b.jpg"]))
    }

    func test_execute_skipsRowsWithNilTarget() {
        var exifCalls: [URL] = []
        let op = DateOperation(bridge: MockCaptureOneBridge(),
            exifWriter: { _, _, u in exifCalls.append(u) },
            exifReader: { _ in nil },
            fsWriter:   { _, _ in },
            reloader:   { _ in })

        let results = op.execute(
            variants: [ev("/a.jpg", target: Date()), ev("/b.jpg", target: nil)],
            defaultTimeZone: utc,
            overwritePolicy: .skipExisting)
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(exifCalls.map(\.path), ["/a.jpg"])
    }

    func test_execute_skipExisting_skipsRowsWhereTargetEqualsCurrent() {
        let same = Date(timeIntervalSince1970: 100)
        var exifCalls: [URL] = []
        let op = DateOperation(bridge: MockCaptureOneBridge(),
            exifWriter: { _, _, u in exifCalls.append(u) },
            exifReader: { _ in nil },
            fsWriter:   { _, _ in },
            reloader:   { _ in })

        let results = op.execute(
            variants: [ev("/a.jpg", target: same, current: same)],
            defaultTimeZone: utc,
            overwritePolicy: .skipExisting)
        XCTAssertEqual(results.count, 0)
        XCTAssertEqual(exifCalls.count, 0)
    }

    func test_execute_overwriteAll_writesEvenWhenEqual() {
        let same = Date(timeIntervalSince1970: 100)
        var exifCalls: [URL] = []
        let op = DateOperation(bridge: MockCaptureOneBridge(),
            exifWriter: { _, _, u in exifCalls.append(u) },
            exifReader: { _ in nil },
            fsWriter:   { _, _ in },
            reloader:   { _ in })

        _ = op.execute(
            variants: [ev("/a.jpg", target: same, current: same)],
            defaultTimeZone: utc,
            overwritePolicy: .overwriteAll)
        XCTAssertEqual(exifCalls.count, 1)
    }

    func test_execute_usesRowTimeZoneOverride_whenPresent() {
        let tokyo = TimeZone(identifier: "Asia/Tokyo")!
        var exifCalls: [TimeZone] = []
        var v = ev("/a.jpg", target: Date())
        v.timeZoneOverride = tokyo

        let op = DateOperation(bridge: MockCaptureOneBridge(),
            exifWriter: { _, tz, _ in exifCalls.append(tz) },
            exifReader: { _ in nil },
            fsWriter:   { _, _ in },
            reloader:   { _ in })

        _ = op.execute(variants: [v], defaultTimeZone: utc, overwritePolicy: .overwriteAll)
        XCTAssertEqual(exifCalls.first?.identifier, "Asia/Tokyo")
    }
}
