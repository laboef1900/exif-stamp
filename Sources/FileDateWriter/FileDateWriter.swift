import Foundation

public enum FileDateWriter {
    public static func setFileSystemDate(_ date: Date, at url: URL) throws {
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw DateOperationError.fileNotFound(path: url.path)
        }
        do {
            try FileManager.default.setAttributes(
                [.modificationDate: date, .creationDate: date],
                ofItemAtPath: url.path
            )
        } catch {
            throw DateOperationError.filesystemDateFailed(path: url.path, underlying: error.localizedDescription)
        }
    }
}
