import SwiftUI

struct HistorySheet: View {
    @ObservedObject var vm: RootViewModel
    let onClose: () -> Void
    @State private var pendingUndoID: UUID?
    @State private var confirmNewer = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("History").font(.headline)
                Spacer()
                Button("Done", action: onClose).keyboardShortcut(.defaultAction)
            }
            if vm.history.isEmpty {
                Text("No apply batches yet.")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(vm.history) { batch in
                        DisclosureGroup {
                            ForEach(batch.items, id: \.filePath) { item in
                                HStack {
                                    Text(item.filename).font(.system(.body, design: .monospaced))
                                    Spacer()
                                    Text(range(item)).foregroundStyle(.secondary).font(.caption)
                                }
                            }
                        } label: {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(batch.timestamp.formatted(date: .abbreviated, time: .shortened))
                                Text(batch.summaryLine).font(.caption).foregroundStyle(.secondary)
                            }
                        }
                        Button("Undo this batch") {
                            pendingUndoID = batch.id
                            let hasNewer = batch.items.contains { item in
                                guard let path = item.backupPath else { return false }
                                let latest = try? BackupStore.latestBackup(for: URL(fileURLWithPath: item.filePath))
                                return latest.map { $0.path != path } ?? false
                            }
                            if hasNewer {
                                confirmNewer = true
                            } else {
                                vm.undoBatch(batch.id, overwriteNewer: true)
                            }
                        }
                    }
                }
            }
        }
        .padding(20)
        .frame(minWidth: 520, minHeight: 360)
        .alert("Newer write exists for some files", isPresented: $confirmNewer) {
            Button("Skip those") {
                if let id = pendingUndoID { vm.undoBatch(id, overwriteNewer: false) }
            }
            Button("Overwrite") {
                if let id = pendingUndoID { vm.undoBatch(id, overwriteNewer: true) }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("A later apply wrote some of these files. Skip them or restore anyway.")
        }
    }

    private func range(_ item: HistoryItem) -> String {
        let f = DateFormatter()
        f.dateStyle = .short
        f.timeStyle = .short
        let a = item.before.map(f.string(from:)) ?? "—"
        let b = item.after.map(f.string(from:)) ?? "—"
        return "\(a) → \(b)"
    }
}
