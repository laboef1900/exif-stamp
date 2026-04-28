import Foundation

public enum CaptureOneBridgeError: Error, Equatable {
    case captureOneNotRunning
    case noDocumentOpen
    case automationPermissionDenied
    case bridgeFailure(String)
}

public protocol CaptureOneBridging {
    /// Reads the user's currently-selected variants from a running Capture One.
    func readSelection() throws -> [VariantInfo]

    /// Asks Capture One to reload metadata for the given file paths so the catalog reflects on-disk EXIF changes.
    func reloadMetadata(for paths: [String]) throws
}
