import SwiftUI

struct ContentView: View {
    @ObservedObject var vm: RootViewModel
    @State private var showingOverwriteSheet = false
    @State private var showingResults = false
    @State private var showingCustomFormatSheet = false
    @State private var popoverRowID: EditableVariant.ID? = nil
    @State private var pendingApplyTarget: RootViewModel.ApplyTarget = .all

    var body: some View {
        VStack(spacing: 0) {
            switch vm.state {
            case .loading:
                ProgressView().padding()
            case .captureOneNotRunning:
                EmptyStateView(kind: .captureOneNotRunning) { vm.loadSelection() }
            case .noDocumentOpen:
                EmptyStateView(kind: .noDocumentOpen) { vm.loadSelection() }
            case .automationPermissionDenied:
                EmptyStateView(kind: .automationPermissionDenied) { vm.loadSelection() }
            case .bridgeError(let s):
                EmptyStateView(kind: .bridgeError(s)) { vm.loadSelection() }
            case .ready:
                if vm.editableVariants.isEmpty {
                    EmptyStateView(kind: .noSelection) { vm.loadSelection() }
                } else {
                    readyContent
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button { vm.loadSelection() } label: { Label("Refresh", systemImage: "arrow.clockwise") }
            }
        }
        .sheet(isPresented: $showingOverwriteSheet) {
            OverwriteWarningSheet(
                datedVariants: vm.rowsNeedingOverwriteConfirmation(target: pendingApplyTarget),
                onSkip: {
                    showingOverwriteSheet = false
                    vm.apply(target: pendingApplyTarget, overwritePolicy: .skipExisting)
                    showingResults = true
                },
                onOverwrite: {
                    showingOverwriteSheet = false
                    vm.apply(target: pendingApplyTarget, overwritePolicy: .overwriteAll)
                    showingResults = true
                },
                onCancel: { showingOverwriteSheet = false }
            )
        }
        .sheet(isPresented: $showingResults) {
            ResultsView(results: vm.results) {
                showingResults = false
                vm.loadSelection()
            }
        }
        .sheet(isPresented: $showingCustomFormatSheet) {
            CustomFilenameFormatSheet(
                customFormat: customFormatBinding,
                sampleFilenames: vm.editableVariants.prefix(20).map(\.info.filename),
                referenceTimeZone: vm.defaultTimeZone,
                onDone: { showingCustomFormatSheet = false }
            )
        }
        .onAppear { vm.loadSelection() }
    }

    @ViewBuilder
    private var readyContent: some View {
        VStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                StrategyPickerSection(
                    strategy: Binding(
                        get: { vm.defaultStrategy },
                        set: { vm.setDefaultStrategy($0) }
                    ),
                    matchedCount: vm.editableVariants.filter { $0.targetDate != nil }.count,
                    totalCount: vm.editableVariants.count,
                    onConfigureCustomFormat: { showingCustomFormatSheet = true }
                )
                TimeZoneFieldView(timeZone: Binding(
                    get: { vm.defaultTimeZone },
                    set: { vm.setDefaultTimeZone($0) }
                ))
                if case .sequential(let start, let interval) = vm.defaultStrategy {
                    DSTAuditView(start: start, interval: interval,
                                 count: vm.editableVariants.count, timeZone: vm.defaultTimeZone)
                }
            }
            .padding(.horizontal)

            EditableVariantsList(
                variants: $vm.editableVariants,
                selection: $vm.tableSelection,
                isSequential: { if case .sequential = vm.defaultStrategy { return true } else { return false } }(),
                onEditTarget: { id, date in vm.editTarget(rowID: id, to: date) },
                onClearLock:  { id in vm.clearLock(rowID: id) },
                onOpenOverride: { id in popoverRowID = id },
                onMove: { src, dst in vm.reorderRows(from: src, to: dst) }
            )
            .popover(isPresented: Binding(
                get: { popoverRowID != nil },
                set: { if !$0 { popoverRowID = nil } }
            )) {
                if let id = popoverRowID, let v = vm.editableVariants.first(where: { $0.id == id }) {
                    RowOverridePopover(
                        variant: v,
                        onSetStrategy: { s in vm.setRowStrategyOverride(rowID: id, strategy: s) },
                        onSetTimeZone: { tz in vm.setRowTZOverride(rowID: id, timeZone: tz) },
                        onClearOverrides: {
                            vm.setRowStrategyOverride(rowID: id, strategy: nil)
                            vm.setRowTZOverride(rowID: id, timeZone: nil)
                        }
                    )
                }
            }

            Divider()

            footerControls
                .padding(.horizontal).padding(.bottom)
        }
        .environment(\.timeZone, vm.defaultTimeZone)
        .environment(\.calendar, {
            var cal = Calendar(identifier: .gregorian)
            cal.timeZone = vm.defaultTimeZone
            return cal
        }())
    }

    private var footerControls: some View {
        let total = vm.editableVariants.count
        let written = vm.editableVariants.filter { $0.targetDate != nil }.count
        let selectedTotal = vm.tableSelection.count
        let selectedWritten = vm.editableVariants.filter { vm.tableSelection.contains($0.id) && $0.targetDate != nil }.count

        return HStack {
            Text("All: \(written) / \(total)").foregroundStyle(.secondary)
            if selectedTotal > 0 {
                Text("· Selected: \(selectedWritten) / \(selectedTotal)").foregroundStyle(.secondary)
            }
            Text("This modifies files in place. Back up first.")
                .font(.footnote).foregroundStyle(.tertiary)
            Spacer()
            Menu("Apply") {
                Button("Apply to all") { promptOrApply(.all) }
                Button("Apply to selected") { promptOrApply(.selected) }
                    .disabled(selectedTotal == 0)
            }
            .keyboardShortcut(.defaultAction)
            .disabled(written == 0)
        }
    }

    private func promptOrApply(_ target: RootViewModel.ApplyTarget) {
        pendingApplyTarget = target
        if vm.rowsNeedingOverwriteConfirmation(target: target).isEmpty {
            vm.apply(target: target, overwritePolicy: .skipExisting)
            showingResults = true
        } else {
            showingOverwriteSheet = true
        }
    }

    private var customFormatBinding: Binding<String> {
        Binding(
            get: {
                if case .fromFilename(let cfg) = vm.defaultStrategy { return cfg.customFormat ?? "" }
                return ""
            },
            set: { newValue in
                vm.setDefaultStrategy(.fromFilename(.init(customFormat: newValue.isEmpty ? nil : newValue)))
            }
        )
    }
}
