import SwiftUI

struct ResultsView: View {
    let results: [WriteResult]
    let onDone: () -> Void

    private var successes: Int { results.filter { $0.isSuccess }.count }
    private var failures: [WriteResult] { results.filter { !$0.isSuccess } }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 16) {
                Label("\(successes) succeeded", systemImage: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                Label("\(failures.count) failed", systemImage: "xmark.octagon.fill")
                    .foregroundStyle(failures.isEmpty ? AnyShapeStyle(.secondary) : AnyShapeStyle(.red))
                Spacer()
                Button("Done", action: onDone).keyboardShortcut(.defaultAction)
            }
            .font(.headline)

            if !failures.isEmpty {
                Divider()
                Text("Failures").font(.subheadline.bold())
                ScrollView {
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(failures, id: \.variant.filePath) { r in
                            VStack(alignment: .leading, spacing: 2) {
                                Text(r.variant.filename).font(.system(.body, design: .monospaced))
                                if case .failure(let e) = r.outcome {
                                    Text(describe(e))
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
                .frame(maxHeight: 240)
            }
        }
        .padding(20)
    }

    private func describe(_ e: DateOperationError) -> String {
        switch e {
        case .fileNotFound:           return "File not found"
        case .fileNotWritable:        return "File not writable"
        case .couldNotReadImage:      return "Could not read image"
        case .formatNotSupported:     return "Format not supported for writing"
        case .writeFailed(_, let u):  return "Write failed: \(u)"
        case .filesystemDateFailed(_, let u): return "EXIF written, but filesystem date failed: \(u)"
        case .backupFailed(_, let u): return "Backup failed, file not written: \(u)"
        case .metadataReloadFailed(let u): return "Files written, but Capture One did not reload metadata: \(u)"
        case .exifToolMissing:        return "Install ExifTool (brew install exiftool) to write RAW"
        case .restoreFailed(_, let u): return "Restore failed: \(u)"
        }
    }
}

#Preview("Mixed") {
    ResultsView(results: [
        WriteResult(variant: .init(filePath: "/p/A.jpg", filename: "A.jpg", currentExifDate: nil), outcome: .success(())),
        WriteResult(variant: .init(filePath: "/p/B.jpg", filename: "B.jpg", currentExifDate: nil),
                    outcome: .failure(.fileNotWritable(path: "/p/B.jpg"))),
    ], onDone: {})
    .frame(width: 480)
}
