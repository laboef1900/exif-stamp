import Foundation

/// Auto-fill strategies for populating each row's target date.
public enum AutoFillStrategy: Equatable {
    case sameDate(Date)
    case fromFilename(FilenamePatternConfig)
    case sequential(start: Date, interval: TimeInterval)
    case shiftBy(TimeInterval)
}
