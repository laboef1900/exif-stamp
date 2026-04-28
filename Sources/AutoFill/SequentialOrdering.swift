import Foundation

/// Computes the target date for a row at a given visual index, given a start
/// date and a per-row interval. Caller is responsible for ensuring the visual
/// order matches the desired sequence (drag-reorder happens at the view-model
/// layer; this is pure arithmetic).
public enum SequentialOrdering {
    public static func target(at index: Int, start: Date, interval: TimeInterval) -> Date {
        return start.addingTimeInterval(interval * Double(index))
    }
}
