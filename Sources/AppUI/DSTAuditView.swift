import SwiftUI

/// Inline warning banner shown next to the Sequential interval field when the
/// computed range crosses a DST boundary in the active time zone.
struct DSTAuditView: View {
    let start: Date
    let interval: TimeInterval
    let count: Int
    let timeZone: TimeZone

    var body: some View {
        if crossesDST {
            Label("Range crosses a DST change. Some times will skip or repeat.",
                  systemImage: "exclamationmark.triangle.fill")
                .font(.caption)
                .foregroundStyle(.orange)
        }
    }

    private var crossesDST: Bool {
        guard count >= 2 else { return false }
        let firstOffset = timeZone.secondsFromGMT(for: start)
        let lastOffset = timeZone.secondsFromGMT(for: start.addingTimeInterval(interval * Double(count - 1)))
        return firstOffset != lastOffset
    }
}
