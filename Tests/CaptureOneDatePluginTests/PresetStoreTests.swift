import XCTest
@testable import CaptureOneDatePlugin

final class PresetStoreTests: XCTestCase {
    private var defaults: UserDefaults!
    private var suite: String!

    override func setUp() {
        super.setUp()
        suite = "c1dp-presets-\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suite)
        defaults.removePersistentDomain(forName: suite)
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: suite)
        super.tearDown()
    }

    func test_saveLoad_roundTripsStrategyAndTZ() {
        let store = PresetStore(defaults: defaults)
        let date = Date(timeIntervalSince1970: 1_700_000_000)
        let preset = Preset(name: "Berlin sequential",
                            strategy: .sequential(start: date, interval: 60),
                            timeZoneIdentifier: "Europe/Berlin")
        store.save(presets: [preset], activeID: preset.id)
        let loaded = store.load()
        XCTAssertEqual(loaded.presets, [preset])
        XCTAssertEqual(loaded.activeID, preset.id)
    }

    func test_corruptData_returnsEmptyList() {
        defaults.set(Data([0x00, 0x01, 0x02]), forKey: PresetStore.presetsKey)
        let loaded = PresetStore(defaults: defaults).load()
        XCTAssertTrue(loaded.presets.isEmpty)
        XCTAssertNil(loaded.activeID)
    }
}
