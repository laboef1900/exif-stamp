import XCTest
@testable import CaptureOneDatePlugin

@MainActor
final class RootViewModelTests: XCTestCase {
    func test_loadSelection_populatesVariants() {
        let mock = MockCaptureOneBridge()
        let v = VariantInfo(filePath: "/a.jpg", filename: "a.jpg", currentExifDate: nil)
        mock.selection = .success([v])
        let vm = RootViewModel(bridge: mock,
                               exifWriter: { _, _ in }, exifReader: { _ in nil },
                               fsWriter:   { _, _ in })
        vm.loadSelection()
        XCTAssertEqual(vm.variants, [v])
        XCTAssertEqual(vm.state, .ready)
    }

    func test_loadSelection_setsCaptureOneNotRunning_onError() {
        let mock = MockCaptureOneBridge()
        mock.selection = .failure(CaptureOneBridgeError.captureOneNotRunning)
        let vm = RootViewModel(bridge: mock,
                               exifWriter: { _, _ in }, exifReader: { _ in nil },
                               fsWriter:   { _, _ in })
        vm.loadSelection()
        XCTAssertEqual(vm.state, .captureOneNotRunning)
    }

    func test_apply_callsDateOperationAndStoresResults() {
        let mock = MockCaptureOneBridge()
        let v = VariantInfo(filePath: "/a.jpg", filename: "a.jpg", currentExifDate: nil)
        mock.selection = .success([v])
        var exifCalls = 0
        let vm = RootViewModel(bridge: mock,
                               exifWriter: { _, _ in exifCalls += 1 },
                               exifReader: { _ in nil },
                               fsWriter:   { _, _ in })
        vm.loadSelection()
        vm.apply(date: Date(), overwritePolicy: .skipExisting)
        XCTAssertEqual(exifCalls, 1)
        XCTAssertEqual(vm.results.count, 1)
    }
}
