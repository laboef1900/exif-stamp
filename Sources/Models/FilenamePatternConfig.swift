import Foundation

/// Configuration for the "from filename" strategy.
/// `customFormat == nil` means built-in patterns only.
public struct FilenamePatternConfig: Equatable {
    public var customFormat: String?

    public init(customFormat: String? = nil) {
        self.customFormat = customFormat
    }
}
