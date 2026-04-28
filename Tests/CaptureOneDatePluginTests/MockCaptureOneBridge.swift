import Foundation
@testable import CaptureOneDatePlugin

final class MockCaptureOneBridge: CaptureOneBridging {
    var selection: Result<[VariantInfo], Error> = .success([])
    private(set) var reloadCalls: [[String]] = []
    var reloadOutcome: Result<Void, Error> = .success(())

    func readSelection() throws -> [VariantInfo] {
        try selection.get()
    }

    func reloadMetadata(for paths: [String]) throws {
        reloadCalls.append(paths)
        try reloadOutcome.get()
    }
}
