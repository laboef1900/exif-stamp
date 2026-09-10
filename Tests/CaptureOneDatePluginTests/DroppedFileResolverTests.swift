import XCTest
@testable import CaptureOneDatePlugin

final class DroppedFileResolverTests: XCTestCase {
    func test_resolve_filesAndFolders_filtersUnsupported() throws {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent("c1dp-drop-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: dir) }

        let jpg = try Fixtures.makeJPEG(date: nil)
        let nested = dir.appendingPathComponent("nested")
        try FileManager.default.createDirectory(at: nested, withIntermediateDirectories: true)
        let nestedJpg = nested.appendingPathComponent("scan.jpg")
        try FileManager.default.copyItem(at: jpg, to: nestedJpg)
        let txt = dir.appendingPathComponent("notes.txt")
        try Data("nope".utf8).write(to: txt)
        defer { try? FileManager.default.removeItem(at: jpg) }

        let outcome = DroppedFileResolver.resolve([jpg, dir], readDate: { _ in nil })
        XCTAssertEqual(outcome.added, 2)
        XCTAssertEqual(outcome.unsupported, 1)
        XCTAssertEqual(Set(outcome.infos.map(\.filename)), Set(["scan.jpg", jpg.lastPathComponent]))
    }

    func test_resolve_skipsAlreadyListedPaths() throws {
        let jpg = try Fixtures.makeJPEG(date: nil)
        defer { try? FileManager.default.removeItem(at: jpg) }
        let outcome = DroppedFileResolver.resolve([jpg], existingPaths: [jpg.path], readDate: { _ in nil })
        XCTAssertEqual(outcome.added, 0)
        XCTAssertTrue(outcome.infos.isEmpty)
    }
}
