import SwiftUI

struct DatePickerSection: View {
    @Binding var date: Date
    let undatedCount: Int
    let datedCount: Int
    let onApply: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            DatePicker("New capture date", selection: $date)
                .datePickerStyle(.field)

            HStack {
                if datedCount > 0 {
                    Label("\(datedCount) of \(undatedCount + datedCount) files already have a date.",
                          systemImage: "exclamationmark.triangle.fill")
                        .foregroundStyle(.orange)
                        .font(.callout)
                } else {
                    Text("\(undatedCount) file\(undatedCount == 1 ? "" : "s") will be updated.")
                        .foregroundStyle(.secondary)
                        .font(.callout)
                }
                Spacer()
                Button("Apply", action: onApply)
                    .keyboardShortcut(.defaultAction)
                    .disabled(undatedCount + datedCount == 0)
            }

            Text("This modifies files in place. Back up first.")
                .font(.footnote)
                .foregroundStyle(.tertiary)
        }
    }
}

#Preview("Mixed") {
    DatePickerSection(date: .constant(Date()), undatedCount: 5, datedCount: 2, onApply: {})
        .padding()
        .frame(width: 600)
}

#Preview("All undated") {
    DatePickerSection(date: .constant(Date()), undatedCount: 5, datedCount: 0, onApply: {})
        .padding()
        .frame(width: 600)
}
