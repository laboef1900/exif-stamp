import Foundation

public struct HistoryItem: Equatable, Codable {
    public let filePath: String
    public let filename: String
    public let before: Date?
    public let after: Date?
    public let backupPath: String?
    public let succeeded: Bool

    public init(filePath: String,
                filename: String,
                before: Date?,
                after: Date?,
                backupPath: String?,
                succeeded: Bool) {
        self.filePath = filePath
        self.filename = filename
        self.before = before
        self.after = after
        self.backupPath = backupPath
        self.succeeded = succeeded
    }
}

public struct HistoryBatch: Identifiable, Equatable, Codable {
    public let id: UUID
    public let timestamp: Date
    public let strategySummary: String
    public let timeZoneIdentifier: String
    public let items: [HistoryItem]

    public init(id: UUID = UUID(),
                timestamp: Date = Date(),
                strategySummary: String,
                timeZoneIdentifier: String,
                items: [HistoryItem]) {
        self.id = id
        self.timestamp = timestamp
        self.strategySummary = strategySummary
        self.timeZoneIdentifier = timeZoneIdentifier
        self.items = items
    }

    public var fileCount: Int { items.filter(\.succeeded).count }

    public var summaryLine: String {
        "\(fileCount) files · \(strategySummary) · \(timeZoneIdentifier)"
    }
}
