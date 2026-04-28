import XCTest
import ImageIO
import UniformTypeIdentifiers

final class FixturesTests: XCTestCase {
    func test_makeJPEGWithoutDate_createsReadableImage() throws {
        let url = try Fixtures.makeJPEG(date: nil)
        defer { try? FileManager.default.removeItem(at: url) }
        let src = CGImageSourceCreateWithURL(url as CFURL, nil)
        XCTAssertNotNil(src)
        let props = CGImageSourceCopyPropertiesAtIndex(src!, 0, nil) as? [CFString: Any]
        let exif = props?[kCGImagePropertyExifDictionary] as? [CFString: Any]
        XCTAssertNil(exif?[kCGImagePropertyExifDateTimeOriginal])
    }

    func test_makeJPEGWithDate_writesDateTimeOriginal() throws {
        let date = Date(timeIntervalSince1970: 1_700_000_000)  // 2023-11-14 22:13:20 UTC
        let url = try Fixtures.makeJPEG(date: date)
        defer { try? FileManager.default.removeItem(at: url) }
        let src = CGImageSourceCreateWithURL(url as CFURL, nil)!
        let props = CGImageSourceCopyPropertiesAtIndex(src, 0, nil) as? [CFString: Any]
        let exif = props?[kCGImagePropertyExifDictionary] as? [CFString: Any]
        XCTAssertNotNil(exif?[kCGImagePropertyExifDateTimeOriginal])
    }
}
