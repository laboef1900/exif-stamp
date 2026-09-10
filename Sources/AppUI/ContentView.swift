import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @ObservedObject var vm: RootViewModel
    @State private var showingOverwriteSheet = false
    @State private var showingResults = false
    @State private var showingCustomFormatSheet = false
    @State private var showingHistory = false
    @State private var showingSavePreset = false
    @State private var showingManagePresets = false
    @State private var savePresetName = ""
    @State private var popoverRowID: EditableVariant.ID? = nil
    @State private var pendingApplyTarget: RootViewModel.ApplyTarget = .all
    @State private var dropTargeted = false

    var body: some View {
        VStack(spacing: 0) {
            mainBody
        }
        .toolbar { toolbarContent }
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
                vm.refreshCurrentRows()
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
        .sheet(isPresented: $showingHistory) {
            HistorySheet(vm: vm, onClose: { showingHistory = false })
        }
        .onAppear {
            vm.pruneBackups()
            if vm.mode == .bridged { vm.loadSelection() }
        }
        .onDrop(of: [UTType.fileURL], isTargeted: $dropTargeted) { providers in
            DropZoneView.loadURLs(from: providers) { vm.openDroppedURLs($0) }
        }
        .onOpenURL { url in
            vm.openDroppedURLs([url])
        }
    }

    @ViewBuilder
    private var mainBody: some View {
        if vm.mode == .dropped && vm.editableVariants.isEmpty {
            DropZoneView(notice: vm.dropNotice, onDrop: { vm.openDroppedURLs($0) })
        } else {
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
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Picker("Mode", selection: Binding(
                get: { vm.mode },
                set: { vm.setMode($0) }
            )) {
                Text("Capture One").tag(RootViewModel.Mode.bridged)
                Text("Drop files").tag(RootViewModel.Mode.dropped)
            }
            .pickerStyle(.segmented)
            .frame(width: 240)
        }
        ToolbarItem(placement: .automatic) {
            PresetsMenu(vm: vm,
                        saveName: $savePresetName,
                        showingSave: $showingSavePreset,
                        showingManage: $showingManagePresets)
        }
        ToolbarItem(placement: .automatic) {
            Button { showingHistory = true } label: {
                Label("History", systemImage: "clock.arrow.circlepath")
            }
        }
        ToolbarItem(placement: .primaryAction) {
            Button { vm.loadSelection() } label: {
                Label("Refresh", systemImage: "arrow.clockwise")
            }
            .disabled(vm.mode == .dropped)
        }
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
                if let notice = vm.dropNotice, vm.mode == .dropped {
                    Text(notice).font(.caption).foregroundStyle(.secondary)
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
                onMove: { src, dst in vm.reorderRows(from: src, to: dst) },
                onRestorePrevious: { id in vm.restorePrevious(rowID: id) },
                canRestore: { id in vm.hasBackup(rowID: id) }
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
                if case .fromFilename(let cfg) = vm.defaultStrategy {
                    return cfg.customFormat ?? ""
                }
                return ""
            },
            set: { newValue in
                vm.setDefaultStrategy(.fromFilename(FilenamePatternConfig(
                    customFormat: newValue.isEmpty ? nil : newValue)))
            }
        )
    }
}
