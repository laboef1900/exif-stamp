import XCTest
@testable import CaptureOneDatePlugin

final class BackupStoreTests: XCTestCase {
    func test_captureBackup_copiesOriginalNextToFile() throws {
        let url = try Fixtures.makeJPEG(date: nil)
        let dir = url.deletingLastPathComponent()
        defer {
            try? FileManager.default.removeItem(at: url)
            try? FileManager.default.removeItem(at: dir.appendingPathComponent(BackupStore.directoryName))
        }
        let original = try Data(contentsOf: url)
        try BackupStore.captureBackup(of: url)
        let backup = try XCTUnwrap(BackupStore.latestBackup(for: url))
        XCTAssertEqual(try Data(contentsOf: backup), original)
        XCTAssertTrue(backup.path.contains(BackupStore.directoryName))
    }

    func test_restoreLatest_replacesFileWithBackup() throws {
        let url = try Fixtures.makeJPEG(date: nil)
        let dir = url.deletingLastPathComponent()
        defer {
            try? FileManager.default.removeItem(at: url)
            try? FileManager.default.removeItem(at: dir.appendingPathComponent(BackupStore.directoryName))
        }
        let original = try Data(contentsOf: url)
        try BackupStore.captureBackup(of: url)
        try Data("mutated".utf8).write(to: url)
        try BackupStore.restoreLatest(of: url)
        XCTAssertEqual(try Data(contentsOf: url), original)
        XCTAssertNotNil(try BackupStore.latestBackup(for: url))
    }

    func test_captureBackup_throwsForMissingFile() {
        let url = URL(fileURLWithPath: "/tmp/c1dp-missing-\(UUID().uuidString).jpg")
        XCTAssertThrowsError(try BackupStore.captureBackup(of: url)) { err in
            guard case DateOperationError.fileNotFound = err else {
                return XCTFail("expected fileNotFound, got \(err)")
            }
        }
    }
}
