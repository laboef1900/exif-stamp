import SwiftUI

struct CustomFilenameFormatSheet: View {
    @Binding var customFormat: String
    let sampleFilenames: [String]
    let referenceTimeZone: TimeZone
    let onDone: () -> Void

    @State private var draft: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Custom filename format").font(.headline)
            Text("Use tokens yyyy / MM / dd / HH / mm / ss for date components. Use * as a wildcard for any text.")
                .font(.caption).foregroundStyle(.secondary)

            TextField("e.g. Scan_yyyyMMdd_HHmmss_*", text: $draft)
                .textFieldStyle(.roundedBorder)

            Divider()

            Text("Preview").font(.callout.weight(.semibold))
            ScrollView {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(sampleFilenames, id: \.self) { name in
                        HStack {
                            Text(name).font(.system(.body, design: .monospaced))
                            Spacer()
                            Text(previewLine(name))
                                .foregroundStyle(previewLine(name) == "—" ? AnyShapeStyle(.tertiary) : AnyShapeStyle(.secondary))
                        }
                    }
                }
            }
            .frame(maxHeight: 220)

            HStack {
                Spacer()
                Button("Cancel") { onDone() }
                Button("Save") {
                    customFormat = draft
                    onDone()
                }.keyboardShortcut(.defaultAction)
            }
        }
        .padding(20)
        .frame(width: 480)
        .onAppear { draft = customFormat }
    }

    private func previewLine(_ name: String) -> String {
        let cfg = FilenamePatternConfig(customFormat: draft.isEmpty ? nil : draft)
        guard let date = FilenameDateParser.parse(name, config: cfg, referenceTimeZone: referenceTimeZone) else {
            return "—"
        }
        let f = DateFormatter(); f.dateStyle = .medium; f.timeStyle = .short
        return f.string(from: date)
    }
}
