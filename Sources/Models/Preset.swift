import Foundation

public struct Preset: Identifiable, Equatable, Codable {
    public var id: UUID
    public var name: String
    public var strategy: AutoFillStrategy
    public var timeZoneIdentifier: String

    public init(id: UUID = UUID(),
                name: String,
                strategy: AutoFillStrategy,
                timeZoneIdentifier: String) {
        self.id = id
        self.name = name
        self.strategy = strategy
        self.timeZoneIdentifier = timeZoneIdentifier
    }

    public static func sameDateBuiltIn(now: Date = Date(),
                                       timeZone: TimeZone = .current) -> Preset {
        Preset(name: "Same date for all",
               strategy: .sameDate(now),
               timeZoneIdentifier: timeZone.identifier)
    }
}
