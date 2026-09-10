import Foundation

public enum DateOperationError: Error, Equatable {
    case fileNotFound(path: String)
    case fileNotWritable(path: String)
    case couldNotReadImage(path: String)
    case formatNotSupported(path: String)
    case writeFailed(path: String, underlying: String)
    case filesystemDateFailed(path: String, underlying: String)
    case backupFailed(path: String, underlying: String)
    case metadataReloadFailed(underlying: String)
}
