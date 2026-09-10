import Foundation

/// Auto-fill strategies for populating each row's target date.
public enum AutoFillStrategy: Equatable {
    case sameDate(Date)
    case fromFilename(FilenamePatternConfig)
    case sequential(start: Date, interval: TimeInterval)
    case shiftBy(TimeInterval)
}

extension AutoFillStrategy: Codable {
    private enum Kind: String, Codable {
        case sameDate, fromFilename, sequential, shiftBy
    }

    private enum CodingKeys: String, CodingKey {
        case kind, date, customFormat, start, interval
    }

    public func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .sameDate(let date):
            try c.encode(Kind.sameDate, forKey: .kind)
            try c.encode(date.timeIntervalSince1970, forKey: .date)
        case .fromFilename(let cfg):
            try c.encode(Kind.fromFilename, forKey: .kind)
            try c.encodeIfPresent(cfg.customFormat, forKey: .customFormat)
        case .sequential(let start, let interval):
            try c.encode(Kind.sequential, forKey: .kind)
            try c.encode(start.timeIntervalSince1970, forKey: .start)
            try c.encode(interval, forKey: .interval)
        case .shiftBy(let interval):
            try c.encode(Kind.shiftBy, forKey: .kind)
            try c.encode(interval, forKey: .interval)
        }
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        switch try c.decode(Kind.self, forKey: .kind) {
        case .sameDate:
            let t = try c.decode(TimeInterval.self, forKey: .date)
            self = .sameDate(Date(timeIntervalSince1970: t))
        case .fromFilename:
            self = .fromFilename(FilenamePatternConfig(
                customFormat: try c.decodeIfPresent(String.self, forKey: .customFormat)))
        case .sequential:
            let t = try c.decode(TimeInterval.self, forKey: .start)
            let i = try c.decode(TimeInterval.self, forKey: .interval)
            self = .sequential(start: Date(timeIntervalSince1970: t), interval: i)
        case .shiftBy:
            self = .shiftBy(try c.decode(TimeInterval.self, forKey: .interval))
        }
    }

    public var summary: String {
        switch self {
        case .sameDate: return "Same date"
        case .fromFilename: return "From filename"
        case .sequential: return "Sequential"
        case .shiftBy: return "Shift by Δ"
        }
    }
}
