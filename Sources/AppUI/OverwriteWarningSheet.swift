import SwiftUI

struct OverwriteWarningSheet: View {
    let datedVariants: [VariantInfo]
    let onSkip: () -> Void
    let onOverwrite: () -> Void
    let onCancel: () -> Void

    private static let f: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f
    }()

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("\(datedVariants.count) file\(datedVariants.count == 1 ? "" : "s") already have a capture date")
                .font(.headline)

            ScrollView {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(datedVariants) { v in
                        HStack {
                            Text(v.filename).font(.system(.body, design: .monospaced))
                            Spacer()
                            Text(Self.f.string(from: v.currentExifDate ?? .distantPast))
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .frame(maxHeight: 240)

            HStack {
                Button("Cancel", role: .cancel, action: onCancel)
                Spacer()
                Button("Skip those", action: onSkip)
                Button("Overwrite all", role: .destructive, action: onOverwrite)
                    .keyboardShortcut(.defaultAction)
            }
        }
        .padding(20)
        .frame(width: 480)
    }
}

#Preview {
    OverwriteWarningSheet(
        datedVariants: [
            VariantInfo(filePath: "/p/A.jpg", filename: "A.jpg",
                        currentExifDate: Date(timeIntervalSince1970: 1_700_000_000)),
            VariantInfo(filePath: "/p/B.jpg", filename: "B.jpg",
                        currentExifDate: Date(timeIntervalSince1970: 1_500_000_000)),
        ],
        onSkip: {}, onOverwrite: {}, onCancel: {}
    )
}
