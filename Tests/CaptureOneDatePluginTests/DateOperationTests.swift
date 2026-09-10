import XCTest
@testable import CaptureOneDatePlugin

final class DateOperationTests: XCTestCase {
    private let utc = TimeZone(secondsFromGMT: 0)!

    private func ev(_ path: String, target: Date?, current: Date? = nil,
                    manuallyEdited: Bool = false) -> EditableVariant {
        EditableVariant(
            info: VariantInfo(filePath: path, filename: (path as NSString).lastPathComponent, currentExifDate: current),
            targetDate: target,
            manuallyEdited: manuallyEdited
        )
    }

    private func makeOp(
        exifWriter: @escaping DateOperation.ExifWrite = { _, _, _ in },
        fsWriter: @escaping DateOperation.FSWrite = { _, _ in },
        reloader: @escaping DateOperation.Reload = { _ in },
        backup: @escaping DateOperation.Backup = { _ in }
    ) -> DateOperation {
        DateOperation(exifWriter: exifWriter, fsWriter: fsWriter, reloader: reloader, backup: backup)
    }

    func test_execute_writesEachRowsTargetDate() {
        let target1 = Date(timeIntervalSince1970: 100)
        let target2 = Date(timeIntervalSince1970: 200)
        var exifCalls: [(Date, URL, TimeZone)] = []
        var fsCalls: [(Date, URL)] = []
        var reloadCalls: [[String]] = []

        let op = makeOp(
            exifWriter: { d, tz, u in exifCalls.append((d, u, tz)) },
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
        let op = makeOp(exifWriter: { _, _, u in exifCalls.append(u) })

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
        let op = makeOp(exifWriter: { _, _, u in exifCalls.append(u) })

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
        let op = makeOp(exifWriter: { _, _, u in exifCalls.append(u) })

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

        let op = makeOp(exifWriter: { _, tz, _ in exifCalls.append(tz) })

        _ = op.execute(variants: [v], defaultTimeZone: utc, overwritePolicy: .overwriteAll)
        XCTAssertEqual(exifCalls.first?.identifier, "Asia/Tokyo")
    }

    func test_execute_skipExisting_skipsDatedRowsEvenWhenTargetDiffers() {
        let current = Date(timeIntervalSince1970: 100)
        let target = Date(timeIntervalSince1970: 200)
        var exifCalls: [URL] = []
        let op = makeOp(exifWriter: { _, _, u in exifCalls.append(u) })

        let results = op.execute(
            variants: [
                ev("/dated.jpg", target: target, current: current),
                ev("/undated.jpg", target: target, current: nil),
            ],
            defaultTimeZone: utc,
            overwritePolicy: .skipExisting)

        XCTAssertEqual(exifCalls.map(\.path), ["/undated.jpg"])
        XCTAssertEqual(results.map(\.variant.filePath), ["/undated.jpg"])
    }

    func test_execute_skipExisting_writesManuallyEditedDatedRows() {
        let current = Date(timeIntervalSince1970: 100)
        let target = Date(timeIntervalSince1970: 200)
        var exifCalls: [URL] = []
        let op = makeOp(exifWriter: { _, _, u in exifCalls.append(u) })

        _ = op.execute(
            variants: [ev("/locked.jpg", target: target, current: current, manuallyEdited: true)],
            defaultTimeZone: utc,
            overwritePolicy: .skipExisting)

        XCTAssertEqual(exifCalls.map(\.path), ["/locked.jpg"])
    }

    func test_execute_overwriteAll_writesDatedRowsWithDifferentTarget() {
        let current = Date(timeIntervalSince1970: 100)
        let target = Date(timeIntervalSince1970: 200)
        var exifCalls: [URL] = []
        let op = makeOp(exifWriter: { _, _, u in exifCalls.append(u) })

        _ = op.execute(
            variants: [ev("/dated.jpg", target: target, current: current)],
            defaultTimeZone: utc,
            overwritePolicy: .overwriteAll)

        XCTAssertEqual(exifCalls.map(\.path), ["/dated.jpg"])
    }

    func test_execute_dedupesDuplicatePaths() {
        var exifCalls: [URL] = []
        let op = makeOp(exifWriter: { _, _, u in exifCalls.append(u) })
        let target = Date()
        _ = op.execute(
            variants: [ev("/a.jpg", target: target), ev("/a.jpg", target: target)],
            defaultTimeZone: utc,
            overwritePolicy: .overwriteAll)
        XCTAssertEqual(exifCalls.map(\.path), ["/a.jpg"])
    }

    func test_execute_backupRunsBeforeWrite() {
        var order: [String] = []
        let op = makeOp(
            exifWriter: { _, _, _ in order.append("exif") },
            fsWriter:   { _, _ in order.append("fs") },
            backup:     { _ in order.append("backup") })
        _ = op.execute(
            variants: [ev("/a.jpg", target: Date())],
            defaultTimeZone: utc,
            overwritePolicy: .overwriteAll)
        XCTAssertEqual(order, ["backup", "exif", "fs"])
    }

    func test_execute_backupFailure_skipsWrite() {
        var exifCalls = 0
        let op = makeOp(
            exifWriter: { _, _, _ in exifCalls += 1 },
            backup: { url in throw DateOperationError.backupFailed(path: url.path, underlying: "disk") })
        let results = op.execute(
            variants: [ev("/a.jpg", target: Date())],
            defaultTimeZone: utc,
            overwritePolicy: .overwriteAll)
        XCTAssertEqual(exifCalls, 0)
        XCTAssertEqual(results.count, 1)
        XCTAssertFalse(results[0].isSuccess)
        if case .failure(.backupFailed) = results[0].outcome {} else {
            XCTFail("expected backupFailed, got \(results[0].outcome)")
        }
    }

    func test_execute_reloadFailure_isReportedAfterSuccessfulWrites() {
        let op = makeOp(
            reloader: { _ in throw CaptureOneBridgeError.bridgeFailure("nope") })
        let results = op.execute(
            variants: [ev("/a.jpg", target: Date())],
            defaultTimeZone: utc,
            overwritePolicy: .overwriteAll)
        XCTAssertEqual(results.count, 2)
        XCTAssertTrue(results[0].isSuccess)
        if case .failure(.metadataReloadFailed) = results[1].outcome {} else {
            XCTFail("expected metadataReloadFailed, got \(results[1].outcome)")
        }
    }
}
