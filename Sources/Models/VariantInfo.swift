import Foundation

/// One image selected in Capture One that we may write a date into.
public struct VariantInfo: Equatable, Hashable, Identifiable {
    public let filePath: String
    public let filename: String
    public let currentExifDate: Date?

    public var id: String { filePath }

    public init(filePath: String, filename: String, currentExifDate: Date?) {
        self.filePath = filePath
        self.filename = filename
        self.currentExifDate = currentExifDate
    }
}
