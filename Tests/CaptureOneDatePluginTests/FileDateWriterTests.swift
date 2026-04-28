import XCTest
@testable import CaptureOneDatePlugin

final class FileDateWriterTests: XCTestCase {
    func test_setFileSystemDate_setsBothCreationAndModification() throws {
        let url = try Fixtures.makeJPEG(date: nil)
        defer { try? FileManager.default.removeItem(at: url) }
        let target = Date(timeIntervalSince1970: 1_700_000_000)
        try FileDateWriter.setFileSystemDate(target, at: url)
        let attrs = try FileManager.default.attributesOfItem(atPath: url.path)
        let mod = attrs[.modificationDate] as? Date
        let cre = attrs[.creationDate] as? Date
        XCTAssertNotNil(mod)
        XCTAssertNotNil(cre)
        XCTAssertLessThan(abs(mod!.timeIntervalSince(target)), 1.5)
        XCTAssertLessThan(abs(cre!.timeIntervalSince(target)), 1.5)
    }

    func test_setFileSystemDate_throwsForMissingFile() {
        let url = URL(fileURLWithPath: "/tmp/c1dp-missing-\(UUID().uuidString).jpg")
        XCTAssertThrowsError(try FileDateWriter.setFileSystemDate(Date(), at: url)) { err in
            guard case DateOperationError.fileNotFound = err else {
                return XCTFail("Expected fileNotFound, got \(err)")
            }
        }
    }
}
