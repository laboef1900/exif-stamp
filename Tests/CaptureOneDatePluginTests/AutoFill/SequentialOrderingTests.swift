import XCTest
@testable import CaptureOneDatePlugin

final class SequentialOrderingTests: XCTestCase {
    private let start = Date(timeIntervalSince1970: 1_700_000_000)

    func test_zeroIndex_isStart() {
        XCTAssertEqual(SequentialOrdering.target(at: 0, start: start, interval: 60), start)
    }

    func test_nonZeroIndex_addsInterval() {
        XCTAssertEqual(SequentialOrdering.target(at: 1, start: start, interval: 60),
                       Date(timeIntervalSince1970: 1_700_000_060))
        XCTAssertEqual(SequentialOrdering.target(at: 5, start: start, interval: 60),
                       Date(timeIntervalSince1970: 1_700_000_300))
    }

    func test_negativeInterval_movesBackwards() {
        XCTAssertEqual(SequentialOrdering.target(at: 2, start: start, interval: -3600),
                       Date(timeIntervalSince1970: 1_699_992_800))
    }

    func test_zeroInterval_allRowsGetStart() {
        XCTAssertEqual(SequentialOrdering.target(at: 9, start: start, interval: 0), start)
    }
}
