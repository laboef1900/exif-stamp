import SwiftUI

struct StrategyPickerSection: View {
    @Binding var strategy: AutoFillStrategy
    let matchedCount: Int
    let totalCount: Int
    let onConfigureCustomFormat: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Text("Auto-fill from:")
                    .font(.callout)
                Picker("", selection: kindBinding) {
                    Text("Same date").tag(StrategyKind.sameDate)
                    Text("From filename").tag(StrategyKind.fromFilename)
                    Text("Sequential").tag(StrategyKind.sequential)
                    Text("Shift by Δ").tag(StrategyKind.shiftBy)
                }
                .labelsHidden()
                .pickerStyle(.menu)
                .frame(width: 160)

                strategyControls
            }

            if case .fromFilename = strategy {
                HStack {
                    Text("Matched \(matchedCount) / \(totalCount)").font(.callout).foregroundStyle(.secondary)
                    Button("Configure custom format…") { onConfigureCustomFormat() }
                }
            }
        }
    }

    @ViewBuilder
    private var strategyControls: some View {
        switch strategy {
        case .sameDate:
            DatePicker("", selection: dateBinding(\.sameDate)).labelsHidden().datePickerStyle(.field)
        case .fromFilename:
            EmptyView()
        case .sequential:
            HStack {
                Text("Start")
                DatePicker("", selection: dateBinding(\.sequentialStart)).labelsHidden().datePickerStyle(.field)
                Text("Interval")
                IntervalField(seconds: intervalBinding(\.sequentialInterval))
            }
        case .shiftBy:
            HStack {
                Text("Δ")
                IntervalField(seconds: intervalBinding(\.shiftDelta))
            }
        }
    }

    // MARK: - Bindings into the AutoFillStrategy enum

    private enum StrategyKind: Hashable { case sameDate, fromFilename, sequential, shiftBy }

    private var kindBinding: Binding<StrategyKind> {
        Binding(
            get: {
                switch strategy {
                case .sameDate: return .sameDate
                case .fromFilename: return .fromFilename
                case .sequential: return .sequential
                case .shiftBy: return .shiftBy
                }
            },
            set: { newKind in
                switch newKind {
                case .sameDate:     strategy = .sameDate(Date())
                case .fromFilename: strategy = .fromFilename(.init())
                case .sequential:   strategy = .sequential(start: Date(), interval: 60)
                case .shiftBy:      strategy = .shiftBy(0)
                }
            }
        )
    }

    private struct StrategyAccessors {
        var sameDate: Date = Date()
        var sequentialStart: Date = Date()
        var sequentialInterval: TimeInterval = 60
        var shiftDelta: TimeInterval = 0
    }

    private func dateBinding(_ keyPath: WritableKeyPath<StrategyAccessors, Date>) -> Binding<Date> {
        Binding(
            get: {
                switch strategy {
                case .sameDate(let d): return d
                case .sequential(let start, _): return start
                default: return Date()
                }
            },
            set: { newDate in
                switch strategy {
                case .sameDate: strategy = .sameDate(newDate)
                case .sequential(_, let interval): strategy = .sequential(start: newDate, interval: interval)
                default: break
                }
            }
        )
    }

    private func intervalBinding(_ keyPath: WritableKeyPath<StrategyAccessors, TimeInterval>) -> Binding<TimeInterval> {
        Binding(
            get: {
                switch strategy {
                case .sequential(_, let interval): return interval
                case .shiftBy(let delta): return delta
                default: return 0
                }
            },
            set: { newSec in
                switch strategy {
                case .sequential(let start, _): strategy = .sequential(start: start, interval: newSec)
                case .shiftBy: strategy = .shiftBy(newSec)
                default: break
                }
            }
        )
    }
}

/// Number + unit input for an interval expressed in seconds. Supports negative
/// values (Shift mode) via signed unit popup.
struct IntervalField: View {
    @Binding var seconds: TimeInterval
    @State private var unit: Unit = .seconds
    @State private var amount: Double = 0

    enum Unit: String, CaseIterable, Identifiable {
        case seconds = "sec", minutes = "min", hours = "hr", days = "day"
        var id: String { rawValue }
        var divisor: Double {
            switch self {
            case .seconds: return 1
            case .minutes: return 60
            case .hours:   return 3600
            case .days:    return 86_400
            }
        }
    }

    var body: some View {
        HStack(spacing: 4) {
            TextField("", value: $amount, format: .number)
                .frame(width: 70)
                .onChange(of: amount) { newAmount in seconds = newAmount * unit.divisor }
            Picker("", selection: $unit) {
                ForEach(Unit.allCases) { Text($0.rawValue).tag($0) }
            }
            .labelsHidden()
            .frame(width: 65)
            .onChange(of: unit) { newUnit in seconds = amount * newUnit.divisor }
        }
        .onAppear { amount = seconds / unit.divisor }
        // Sync the local amount when the bound seconds value changes externally —
        // e.g., the strategy popup switches to a new strategy with its own default.
        .onChange(of: seconds) { newSec in
            let derived = newSec / unit.divisor
            if abs(derived - amount) > 0.0001 { amount = derived }
        }
    }
}
