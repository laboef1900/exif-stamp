import SwiftUI

struct EditableVariantsList: View {
    @Binding var variants: [EditableVariant]
    @Binding var selection: Set<EditableVariant.ID>
    let isSequential: Bool
    let onEditTarget: (EditableVariant.ID, Date?) -> Void
    let onClearLock: (EditableVariant.ID) -> Void
    let onOpenOverride: (EditableVariant.ID) -> Void
    let onMove: (IndexSet, Int) -> Void

    private static let f: DateFormatter = {
        let f = DateFormatter(); f.dateStyle = .medium; f.timeStyle = .short; return f
    }()

    var body: some View {
        List(selection: $selection) {
            // Header row
            HStack {
                if isSequential { Text("⇅").frame(width: 18) }
                Text("Filename").frame(maxWidth: .infinity, alignment: .leading)
                Text("Current").frame(width: 140, alignment: .leading)
                Text("Target").frame(width: 200, alignment: .leading)
                Text("").frame(width: 40)
            }
            .font(.caption.weight(.semibold))
            .foregroundStyle(.secondary)
            .listRowSeparator(.hidden)

            ForEach($variants) { $v in
                row(for: $v)
                    .tag(v.id)
            }
            .onMove(perform: isSequential ? onMove : nil)
        }
        .listStyle(.inset(alternatesRowBackgrounds: true))
        .frame(minHeight: 200)
    }

    @ViewBuilder
    private func row(for v: Binding<EditableVariant>) -> some View {
        HStack {
            if isSequential { Text("⇅").frame(width: 18).foregroundStyle(.tertiary) }
            Text(v.wrappedValue.info.filename)
                .font(.system(.body, design: .monospaced))
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(v.wrappedValue.info.currentExifDate.map(Self.f.string(from:)) ?? "—")
                .frame(width: 140, alignment: .leading)
                .foregroundStyle(.secondary)
            HStack(spacing: 4) {
                if let target = v.wrappedValue.targetDate {
                    DatePicker("", selection: Binding(
                        get: { target },
                        set: { onEditTarget(v.wrappedValue.id, $0) }
                    ))
                    .labelsHidden()
                    .datePickerStyle(.field)
                } else {
                    Text("—").foregroundStyle(.tertiary)
                }
                if v.wrappedValue.manuallyEdited {
                    Button { onClearLock(v.wrappedValue.id) } label: {
                        Image(systemName: "lock.fill").foregroundStyle(.orange)
                    }
                    .buttonStyle(.plain)
                    .help("Manually edited — click to clear")
                }
                if v.wrappedValue.strategyOverride != nil {
                    Image(systemName: "circle.fill").font(.system(size: 8)).foregroundStyle(.blue)
                        .help("Per-row strategy override active")
                }
            }
            .frame(width: 200)
            Button { onOpenOverride(v.wrappedValue.id) } label: {
                Image(systemName: "ellipsis.circle")
            }
            .buttonStyle(.plain)
            .frame(width: 40)
        }
    }
}

