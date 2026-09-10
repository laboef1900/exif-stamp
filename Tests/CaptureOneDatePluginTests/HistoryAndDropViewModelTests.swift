import XCTest
@testable import CaptureOneDatePlugin

@MainActor
final class HistoryAndDropViewModelTests: XCTestCase {
    private let utc = TimeZone(secondsFromGMT: 0)!

    private func makeDefaults() -> UserDefaults {
        let name = "c1dp-vm-\(UUID().uuidString)"
        let d = UserDefaults(suiteName: name)!
        d.removePersistentDomain(forName: name)
        return d
    }

    private func makeVM(_ mock: MockCaptureOneBridge,
                        defaults: UserDefaults? = nil,
                        backup: @escaping DateOperation.Backup = { _ in }) -> RootViewModel {
        RootViewModel(
            bridge: mock,
            exifWriter: { _, _, _ in },
            exifReader: { _ in nil },
            fsWriter: { _, _ in },
            backup: backup,
            defaults: defaults ?? makeDefaults())
    }

    func test_emptyStore_seedsSameDatePreset() {
        let vm = makeVM(MockCaptureOneBridge())
        XCTAssertEqual(vm.presets.count, 1)
        XCTAssertEqual(vm.presets.first?.name, "Same date for all")
        XCTAssertEqual(vm.activePresetID, vm.presets.first?.id)
    }

    func test_applyPreset_replacesDefaultStrategyWithoutClearingLocks() {
        let mock = MockCaptureOneBridge()
        mock.selection = .success([
            VariantInfo(filePath: "/a.jpg", filename: "a.jpg", currentExifDate: nil)
        ])
        let vm = makeVM(mock)
        vm.loadSelection()
        vm.editTarget(rowID: "/a.jpg", to: Date(timeIntervalSince1970: 1))
        let seq = Preset(name: "Seq",
                         strategy: .sequential(start: Date(timeIntervalSince1970: 10), interval: 5),
                         timeZoneIdentifier: "UTC")
        vm.presets.append(seq)
        vm.applyPreset(seq)
        XCTAssertEqual(vm.defaultStrategy, seq.strategy)
        XCTAssertTrue(vm.editableVariants[0].manuallyEdited)
        XCTAssertEqual(vm.editableVariants[0].targetDate, Date(timeIntervalSince1970: 1))
    }

    func test_setMode_dropped_clearsTable() {
        let mock = MockCaptureOneBridge()
        mock.selection = .success([
            VariantInfo(filePath: "/a.jpg", filename: "a.jpg", currentExifDate: nil)
        ])
        let vm = makeVM(mock)
        vm.loadSelection()
        XCTAssertEqual(vm.editableVariants.count, 1)
        vm.setMode(.dropped)
        XCTAssertTrue(vm.editableVariants.isEmpty)
        XCTAssertEqual(vm.state, .ready)
    }

    func test_openDroppedURLs_switchesToDropMode() throws {
        let jpg = try Fixtures.makeJPEG(date: nil)
        defer { try? FileManager.default.removeItem(at: jpg) }
        let vm = makeVM(MockCaptureOneBridge())
        vm.openDroppedURLs([jpg])
        XCTAssertEqual(vm.mode, .dropped)
        XCTAssertEqual(vm.editableVariants.count, 1)
        XCTAssertEqual(vm.editableVariants[0].info.filePath, jpg.path)
    }

    func test_apply_recordsHistoryBatch() {
        let mock = MockCaptureOneBridge()
        mock.selection = .success([
            VariantInfo(filePath: "/a.jpg", filename: "a.jpg", currentExifDate: nil)
        ])
        let vm = makeVM(mock)
        vm.loadSelection()
        vm.setDefaultStrategy(.sameDate(Date(timeIntervalSince1970: 50)))
        vm.apply(target: .all, overwritePolicy: .overwriteAll)
        XCTAssertEqual(vm.history.count, 1)
        XCTAssertEqual(vm.history[0].items.first?.filename, "a.jpg")
        XCTAssertTrue(vm.history[0].items.first?.succeeded ?? false)
    }

    func test_apply_inDropMode_doesNotCallReload() {
        let mock = MockCaptureOneBridge()
        let vm = makeVM(mock)
        vm.setMode(.dropped)
        let info = VariantInfo(filePath: "/a.jpg", filename: "a.jpg", currentExifDate: nil)
        vm.editableVariants = [EditableVariant(info: info, targetDate: Date())]
        vm.apply(target: .all, overwritePolicy: .overwriteAll)
        XCTAssertTrue(mock.reloadCalls.isEmpty)
    }
}
