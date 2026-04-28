import XCTest
@testable import CaptureOneDatePlugin

@MainActor
final class RootViewModelV11Tests: XCTestCase {
    private let utc = TimeZone(secondsFromGMT: 0)!

    private func makeVM(_ mock: MockCaptureOneBridge,
                        exifWriter: @escaping DateOperation.ExifWrite = { _, _, _ in }) -> RootViewModel {
        RootViewModel(
            bridge: mock,
            exifWriter: exifWriter,
            exifReader: { _ in nil },
            fsWriter:   { _, _ in })
    }

    func test_loadSelection_populatesEditableVariants() {
        let mock = MockCaptureOneBridge()
        let info = VariantInfo(filePath: "/a.jpg", filename: "a.jpg", currentExifDate: nil)
        mock.selection = .success([info])
        let vm = makeVM(mock)
        vm.loadSelection()
        XCTAssertEqual(vm.editableVariants.map(\.info), [info])
        XCTAssertEqual(vm.state, .ready)
    }

    func test_setDefaultStrategy_sameDate_fillsAllNonLockedRows() {
        let mock = MockCaptureOneBridge()
        mock.selection = .success([
            VariantInfo(filePath: "/a.jpg", filename: "a.jpg", currentExifDate: nil),
            VariantInfo(filePath: "/b.jpg", filename: "b.jpg", currentExifDate: nil),
        ])
        let vm = makeVM(mock)
        vm.loadSelection()
        let date = Date(timeIntervalSince1970: 100)
        vm.setDefaultStrategy(.sameDate(date))
        XCTAssertEqual(vm.editableVariants[0].targetDate, date)
        XCTAssertEqual(vm.editableVariants[1].targetDate, date)
    }

    func test_editTarget_marksRowAsManuallyEdited_andStrategySwitchPreserves() {
        let mock = MockCaptureOneBridge()
        mock.selection = .success([
            VariantInfo(filePath: "/a.jpg", filename: "a.jpg", currentExifDate: nil),
        ])
        let vm = makeVM(mock)
        vm.loadSelection()
        let manual = Date(timeIntervalSince1970: 200)
        vm.editTarget(rowID: "/a.jpg", to: manual)
        XCTAssertTrue(vm.editableVariants[0].manuallyEdited)
        XCTAssertEqual(vm.editableVariants[0].targetDate, manual)
        vm.setDefaultStrategy(.sameDate(Date(timeIntervalSince1970: 999)))
        XCTAssertEqual(vm.editableVariants[0].targetDate, manual)  // sticky
    }

    func test_clearLock_recomputesFromActiveStrategy() {
        let mock = MockCaptureOneBridge()
        mock.selection = .success([
            VariantInfo(filePath: "/a.jpg", filename: "a.jpg", currentExifDate: nil),
        ])
        let vm = makeVM(mock)
        vm.loadSelection()
        let strategyDate = Date(timeIntervalSince1970: 100)
        vm.setDefaultStrategy(.sameDate(strategyDate))
        vm.editTarget(rowID: "/a.jpg", to: Date(timeIntervalSince1970: 200))
        vm.clearLock(rowID: "/a.jpg")
        XCTAssertFalse(vm.editableVariants[0].manuallyEdited)
        XCTAssertEqual(vm.editableVariants[0].targetDate, strategyDate)
    }

    func test_setRowStrategyOverride_takesPrecedence_overDefault() {
        let mock = MockCaptureOneBridge()
        mock.selection = .success([
            VariantInfo(filePath: "/a.jpg", filename: "a.jpg", currentExifDate: nil),
            VariantInfo(filePath: "/b.jpg", filename: "b.jpg", currentExifDate: nil),
        ])
        let vm = makeVM(mock)
        vm.loadSelection()
        vm.setDefaultStrategy(.sameDate(Date(timeIntervalSince1970: 100)))
        vm.setRowStrategyOverride(rowID: "/b.jpg", strategy: .sameDate(Date(timeIntervalSince1970: 999)))
        XCTAssertEqual(vm.editableVariants[0].targetDate, Date(timeIntervalSince1970: 100))
        XCTAssertEqual(vm.editableVariants[1].targetDate, Date(timeIntervalSince1970: 999))
    }

    func test_apply_all_writesEveryRowWithTarget() {
        let mock = MockCaptureOneBridge()
        mock.selection = .success([
            VariantInfo(filePath: "/a.jpg", filename: "a.jpg", currentExifDate: nil),
            VariantInfo(filePath: "/b.jpg", filename: "b.jpg", currentExifDate: nil),
        ])
        var exifCalls = 0
        let vm = makeVM(mock, exifWriter: { _, _, _ in exifCalls += 1 })
        vm.loadSelection()
        vm.setDefaultStrategy(.sameDate(Date()))
        vm.apply(target: .all, overwritePolicy: .skipExisting)
        XCTAssertEqual(exifCalls, 2)
        XCTAssertEqual(vm.results.count, 2)
    }

    func test_apply_selected_writesOnlySelectedRows() {
        let mock = MockCaptureOneBridge()
        mock.selection = .success([
            VariantInfo(filePath: "/a.jpg", filename: "a.jpg", currentExifDate: nil),
            VariantInfo(filePath: "/b.jpg", filename: "b.jpg", currentExifDate: nil),
        ])
        var exifCalls: [URL] = []
        let vm = makeVM(mock, exifWriter: { _, _, u in exifCalls.append(u) })
        vm.loadSelection()
        vm.setDefaultStrategy(.sameDate(Date()))
        vm.tableSelection = ["/b.jpg"]
        vm.apply(target: .selected, overwritePolicy: .skipExisting)
        XCTAssertEqual(exifCalls.map(\.path), ["/b.jpg"])
    }

    func test_reorderRows_recomputes_underSequentialStrategy() {
        let mock = MockCaptureOneBridge()
        mock.selection = .success([
            VariantInfo(filePath: "/a.jpg", filename: "a.jpg", currentExifDate: nil),
            VariantInfo(filePath: "/b.jpg", filename: "b.jpg", currentExifDate: nil),
            VariantInfo(filePath: "/c.jpg", filename: "c.jpg", currentExifDate: nil),
        ])
        let vm = makeVM(mock)
        vm.loadSelection()
        let start = Date(timeIntervalSince1970: 0)
        vm.setDefaultStrategy(.sequential(start: start, interval: 60))
        XCTAssertEqual(vm.editableVariants[0].targetDate, start)                              // index 0
        XCTAssertEqual(vm.editableVariants[2].targetDate, Date(timeIntervalSince1970: 120))   // index 2
        // Move /c.jpg to the front (index 0).
        vm.reorderRows(from: IndexSet(integer: 2), to: 0)
        XCTAssertEqual(vm.editableVariants[0].info.filePath, "/c.jpg")
        XCTAssertEqual(vm.editableVariants[0].targetDate, start)                              // c is now index 0
    }

    func test_setDefaultTimeZone_recomputesFilenameStrategy_withNewTZ() {
        let mock = MockCaptureOneBridge()
        mock.selection = .success([
            VariantInfo(filePath: "/IMG_20210315_142030.jpg", filename: "IMG_20210315_142030.jpg",
                        currentExifDate: nil),
        ])
        let vm = makeVM(mock)
        vm.loadSelection()
        vm.setDefaultStrategy(.fromFilename(.init()))

        // Switching the default TZ shifts how the parsed wall-clock date
        // relates to seconds-since-epoch (the parser interprets filename digits
        // as wall-clock in the reference TZ).
        let utcDate = vm.editableVariants[0].targetDate!
        vm.setDefaultTimeZone(TimeZone(identifier: "America/Los_Angeles")!)
        let laDate = vm.editableVariants[0].targetDate!
        XCTAssertNotEqual(utcDate, laDate)
        // LA is behind UTC, so the same wall-clock filename "14:20:30" parsed
        // against LA TZ yields a later UTC instant than parsed against UTC.
        XCTAssertGreaterThan(laDate, utcDate)
    }

    func test_setRowTZOverride_persistsAcrossRecomputes() {
        let mock = MockCaptureOneBridge()
        mock.selection = .success([
            VariantInfo(filePath: "/a.jpg", filename: "a.jpg", currentExifDate: nil),
            VariantInfo(filePath: "/b.jpg", filename: "b.jpg", currentExifDate: nil),
        ])
        let vm = makeVM(mock)
        vm.loadSelection()
        let tokyo = TimeZone(identifier: "Asia/Tokyo")!
        vm.setRowTZOverride(rowID: "/a.jpg", timeZone: tokyo)
        XCTAssertEqual(vm.editableVariants[0].timeZoneOverride?.identifier, "Asia/Tokyo")
        XCTAssertNil(vm.editableVariants[1].timeZoneOverride)

        // Strategy switch must not clear per-row TZ override.
        vm.setDefaultStrategy(.sameDate(Date()))
        XCTAssertEqual(vm.editableVariants[0].timeZoneOverride?.identifier, "Asia/Tokyo")
    }
}
