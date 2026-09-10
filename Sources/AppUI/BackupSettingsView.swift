import SwiftUI

struct BackupSettingsView: View {
    @AppStorage(RootViewModel.maxAgeDaysKey) private var maxAgeDays = 30
    @AppStorage(RootViewModel.maxSizeMBKey) private var maxSizeMB = 1024

    var body: some View {
        Form {
            Section("Backups") {
                Stepper("Keep for \(maxAgeDays) days", value: $maxAgeDays, in: 1...365)
                Stepper("Max \(maxSizeMB) MB per folder", value: $maxSizeMB, in: 10...10_000, step: 10)
                Text("Pruned on launch. Backups live in .c1dp-backups next to each photo.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
        .frame(minWidth: 360, minHeight: 160)
    }
}
