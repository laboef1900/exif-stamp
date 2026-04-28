import SwiftUI

struct RowOverridePopover: View {
    let variant: EditableVariant
    let onSetStrategy: (AutoFillStrategy?) -> Void
    let onSetTimeZone: (TimeZone?) -> Void
    let onClearOverrides: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Row override").font(.headline)
            Text(variant.info.filename).font(.system(.callout, design: .monospaced)).foregroundStyle(.secondary)

            Divider()

            HStack {
                Text("Strategy:")
                Picker("", selection: kindBinding) {
                    Text("Inherit default").tag(OverrideKind.inherit)
                    Text("Same date").tag(OverrideKind.sameDate)
                    Text("From filename").tag(OverrideKind.fromFilename)
                    Text("Shift by Δ").tag(OverrideKind.shiftBy)
                }
                .labelsHidden()
                .frame(width: 200)
            }

            HStack {
                Text("Time zone:")
                Picker("", selection: tzBinding) {
                    Text("Inherit default").tag(TimeZoneOption.inherit)
                    ForEach(TimeZone.knownTimeZoneIdentifiers.sorted(), id: \.self) { id in
                        Text(id).tag(TimeZoneOption.specific(id))
                    }
                }
                .labelsHidden()
                .frame(width: 280)
            }

            Divider()

            HStack {
                Spacer()
                Button("Clear overrides for this row") { onClearOverrides() }
            }
        }
        .padding(16)
        .frame(width: 360)
    }

    private enum OverrideKind: Hashable { case inherit, sameDate, fromFilename, shiftBy }
    private enum TimeZoneOption: Hashable { case inherit, specific(String) }

    private var kindBinding: Binding<OverrideKind> {
        Binding(
            get: {
                guard let s = variant.strategyOverride else { return .inherit }
                switch s {
                case .sameDate: return .sameDate
                case .fromFilename: return .fromFilename
                case .sequential: return .inherit  // Sequential makes no sense per-row; collapse to inherit.
                case .shiftBy: return .shiftBy
                }
            },
            set: { newKind in
                switch newKind {
                case .inherit:      onSetStrategy(nil)
                case .sameDate:     onSetStrategy(.sameDate(Date()))
                case .fromFilename: onSetStrategy(.fromFilename(.init()))
                case .shiftBy:      onSetStrategy(.shiftBy(0))
                }
            }
        )
    }

    private var tzBinding: Binding<TimeZoneOption> {
        Binding(
            get: {
                if let tz = variant.timeZoneOverride { return .specific(tz.identifier) }
                return .inherit
            },
            set: { opt in
                switch opt {
                case .inherit:               onSetTimeZone(nil)
                case .specific(let id):      onSetTimeZone(TimeZone(identifier: id))
                }
            }
        )
    }
}
