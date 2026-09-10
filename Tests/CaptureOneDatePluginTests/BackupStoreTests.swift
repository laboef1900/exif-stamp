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

    func test_prune_deletesBackupsOlderThanMaxAge() throws {
        let url = try Fixtures.makeJPEG(date: nil)
        let dir = url.deletingLastPathComponent()
        let backupDir = dir.appendingPathComponent(BackupStore.directoryName)
        defer {
            try? FileManager.default.removeItem(at: url)
            try? FileManager.default.removeItem(at: backupDir)
        }
        try FileManager.default.createDirectory(at: backupDir, withIntermediateDirectories: true)
        let old = backupDir.appendingPathComponent("\(url.lastPathComponent).100.bak")
        let recent = backupDir.appendingPathComponent("\(url.lastPathComponent).\(Int(Date().timeIntervalSince1970)).bak")
        try Data("old".utf8).write(to: old)
        try Data("new".utf8).write(to: recent)
        try BackupStore.prune(directories: [backupDir], maxAgeDays: 1, maxSizeMB: 1024,
                              now: Date(timeIntervalSince1970: 1_700_000_000))
        XCTAssertFalse(FileManager.default.fileExists(atPath: old.path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: recent.path))
    }
}
