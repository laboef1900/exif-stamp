import SwiftUI

struct TimeZoneFieldView: View {
    @Binding var timeZone: TimeZone

    private var allIdentifiers: [String] {
        TimeZone.knownTimeZoneIdentifiers.sorted()
    }

    var body: some View {
        HStack(spacing: 8) {
            Text("Time zone:").font(.callout)
            Picker("", selection: identifierBinding) {
                ForEach(allIdentifiers, id: \.self) { id in
                    Text("\(id) (\(offsetString(for: id)))").tag(id)
                }
            }
            .labelsHidden()
            .frame(width: 320)

            Text("written into OffsetTimeOriginal")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
    }

    private var identifierBinding: Binding<String> {
        Binding(
            get: { timeZone.identifier },
            set: { newID in if let tz = TimeZone(identifier: newID) { timeZone = tz } }
        )
    }

    private func offsetString(for id: String) -> String {
        guard let tz = TimeZone(identifier: id) else { return "" }
        let secs = tz.secondsFromGMT(for: Date())
        let sign = secs >= 0 ? "+" : "-"
        let abs = Swift.abs(secs)
        return String(format: "%@%02d:%02d", sign, abs / 3600, (abs % 3600) / 60)
    }
}
