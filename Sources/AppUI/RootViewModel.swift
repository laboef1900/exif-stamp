import Foundation
import Combine

@MainActor
public final class RootViewModel: ObservableObject {
    public enum UIState: Equatable {
        case loading
        case ready
        case captureOneNotRunning
        case noDocumentOpen
        case automationPermissionDenied
        case bridgeError(String)
    }

    public enum ApplyTarget { case all, selected }
    public enum Mode: String { case bridged, dropped }

    @Published public private(set) var state: UIState = .loading
    @Published public var editableVariants: [EditableVariant] = []
    @Published public private(set) var results: [WriteResult] = []
    @Published public var defaultStrategy: AutoFillStrategy = .sameDate(Date())
    @Published public var defaultTimeZone: TimeZone = .current
    @Published public var tableSelection: Set<EditableVariant.ID> = []
    @Published public var mode: Mode = .bridged
    @Published public var presets: [Preset] = []
    @Published public var activePresetID: UUID?
    @Published public var history: [HistoryBatch] = []
    @Published public var dropNotice: String?
    @Published public var lastUndoHadNewerFiles = false

    public static let maxAgeDaysKey = "app.captureonedate.backupMaxAgeDays"
    public static let maxSizeMBKey = "app.captureonedate.backupMaxSizeMB"

    private let bridge: CaptureOneBridging
    private let exifReader: DateOperation.ExifRead
    private let operation: DateOperation
    private let presetStore: PresetStore
    private let historyStore: HistoryStore
    private let defaults: UserDefaults

    public init(bridge: CaptureOneBridging,
                exifWriter: @escaping DateOperation.ExifWrite,
                exifReader: @escaping DateOperation.ExifRead,
                fsWriter:   @escaping DateOperation.FSWrite,
                backup:     @escaping DateOperation.Backup = { _ in },
                defaults: UserDefaults = .standard) {
        self.bridge = bridge
        self.exifReader = exifReader
        self.defaults = defaults
        self.presetStore = PresetStore(defaults: defaults)
        self.historyStore = HistoryStore(defaults: defaults)
        self.operation = DateOperation(
            exifWriter: exifWriter,
            fsWriter: fsWriter,
            reloader: { _ in },
            backup: backup
        )
        let loaded = presetStore.load()
        if loaded.presets.isEmpty {
            let builtIn = Preset.sameDateBuiltIn(now: Date(), timeZone: .current)
            presets = [builtIn]
            activePresetID = builtIn.id
            presetStore.save(presets: presets, activeID: activePresetID)
        } else {
            presets = loaded.presets
            activePresetID = loaded.activeID
        }
        history = historyStore.load()
        if let id = activePresetID, let p = presets.first(where: { $0.id == id }) {
            defaultStrategy = p.strategy
            defaultTimeZone = TimeZone(identifier: p.timeZoneIdentifier) ?? .current
        }
    }


    // MARK: - Selection loading

    public func loadSelection() {
        guard mode == .bridged else {
            state = .ready
            return
        }
        state = .loading
        do {
            let infos = try bridge.readSelection()
            var seen = Set<String>()
            editableVariants = infos.compactMap { info in
                guard seen.insert(info.filePath).inserted else { return nil }
                let url = URL(fileURLWithPath: info.filePath)
                let fileDate = (try? exifReader(url)) ?? info.currentExifDate
                return EditableVariant(info: VariantInfo(
                    filePath: info.filePath,
                    filename: info.filename,
                    currentExifDate: fileDate))
            }
            recomputeAll()
            state = .ready
        } catch CaptureOneBridgeError.captureOneNotRunning {
            state = .captureOneNotRunning
        } catch CaptureOneBridgeError.noDocumentOpen {
            state = .noDocumentOpen
        } catch CaptureOneBridgeError.automationPermissionDenied {
            state = .automationPermissionDenied
        } catch {
            state = .bridgeError(error.localizedDescription)
        }
    }

    public func setMode(_ newMode: Mode) {
        guard mode != newMode else { return }
        mode = newMode
        tableSelection = []
        dropNotice = nil
        if newMode == .dropped {
            editableVariants = []
            state = .ready
        } else {
            loadSelection()
        }
    }

    public func openDroppedURLs(_ urls: [URL]) {
        if mode != .dropped { setMode(.dropped) }
        let existing = Set(editableVariants.map(\.info.filePath))
        let outcome = DroppedFileResolver.resolve(urls, existingPaths: existing, readDate: exifReader)
        editableVariants.append(contentsOf: outcome.infos.map { EditableVariant(info: $0) })
        recomputeAll()
        state = .ready
        if outcome.unsupported > 0 {
            dropNotice = "\(outcome.added) files added, \(outcome.unsupported) unsupported"
        } else if outcome.added > 0 {
            dropNotice = "\(outcome.added) files added"
        }
    }

    public func refreshCurrentRows() {
        if mode == .bridged {
            loadSelection()
            return
        }
        editableVariants = editableVariants.map { row in
            let url = URL(fileURLWithPath: row.info.filePath)
            let date = try? exifReader(url)
            return EditableVariant(
                info: VariantInfo(filePath: row.info.filePath, filename: row.info.filename, currentExifDate: date),
                targetDate: row.targetDate,
                manuallyEdited: row.manuallyEdited,
                strategyOverride: row.strategyOverride,
                timeZoneOverride: row.timeZoneOverride)
        }
        recomputeAll()
        state = .ready
    }

    // MARK: - Strategy / TZ defaults

    public func setDefaultStrategy(_ s: AutoFillStrategy) {
        defaultStrategy = s
        clearActivePresetIfDiverged()
        recomputeAll()
    }

    public func setDefaultTimeZone(_ tz: TimeZone) {
        defaultTimeZone = tz
        clearActivePresetIfDiverged()
        recomputeAll()
    }

    public func applyPreset(_ preset: Preset) {
        activePresetID = preset.id
        defaultStrategy = preset.strategy
        defaultTimeZone = TimeZone(identifier: preset.timeZoneIdentifier) ?? .current
        presetStore.save(presets: presets, activeID: activePresetID)
        recomputeAll()
    }

    public func saveCurrentAsPreset(name: String) {
        let p = Preset(name: name, strategy: defaultStrategy, timeZoneIdentifier: defaultTimeZone.identifier)
        presets.append(p)
        activePresetID = p.id
        presetStore.save(presets: presets, activeID: activePresetID)
    }

    public func renamePreset(id: UUID, to name: String) {
        guard let i = presets.firstIndex(where: { $0.id == id }) else { return }
        presets[i].name = name
        presetStore.save(presets: presets, activeID: activePresetID)
    }

    public func deletePreset(id: UUID) {
        presets.removeAll { $0.id == id }
        if activePresetID == id { activePresetID = presets.first?.id }
        presetStore.save(presets: presets, activeID: activePresetID)
    }

    public func movePreset(from source: IndexSet, to destination: Int) {
        presets.move(fromOffsets: source, toOffset: destination)
        presetStore.save(presets: presets, activeID: activePresetID)
    }

    // MARK: - Per-row mutations

    public func editTarget(rowID: EditableVariant.ID, to date: Date?) {
        mutate(rowID) {
            $0.targetDate = date
            $0.manuallyEdited = true
        }
    }

    public func clearLock(rowID: EditableVariant.ID) {
        mutate(rowID) { $0.manuallyEdited = false }
        recomputeRow(rowID)
    }

    public func setRowStrategyOverride(rowID: EditableVariant.ID, strategy: AutoFillStrategy?) {
        mutate(rowID) { $0.strategyOverride = strategy }
        recomputeRow(rowID)
    }

    public func setRowTZOverride(rowID: EditableVariant.ID, timeZone: TimeZone?) {
        mutate(rowID) { $0.timeZoneOverride = timeZone }
        recomputeRow(rowID)
    }

    public func reorderRows(from source: IndexSet, to destination: Int) {
        var copy = editableVariants
        copy.move(fromOffsets: source, toOffset: destination)
        editableVariants = copy
        recomputeAll()
    }

    // MARK: - Apply / history

    public func apply(target: ApplyTarget, overwritePolicy: DateOperation.OverwritePolicy) {
        let batchVariants = variants(for: target)
        var produced = operation.execute(
            variants: batchVariants,
            defaultTimeZone: defaultTimeZone,
            overwritePolicy: overwritePolicy)
        if mode == .bridged {
            let written = produced.compactMap { $0.isSuccess ? $0.variant.filePath : nil }
            if !written.isEmpty {
                do {
                    try bridge.reloadMetadata(for: written)
                } catch {
                    produced.append(WriteResult(
                        variant: VariantInfo(filePath: written[0], filename: "Capture One metadata reload", currentExifDate: nil),
                        outcome: .failure(.metadataReloadFailed(underlying: error.localizedDescription))))
                }
            }
        }
        results = produced
        let items: [HistoryItem] = results.compactMap { r in
            guard r.variant.filename != "Capture One metadata reload" else { return nil }
            let source = batchVariants.first { $0.info.filePath == r.variant.filePath }
            let backup = try? BackupStore.latestBackup(for: URL(fileURLWithPath: r.variant.filePath))
            return HistoryItem(
                filePath: r.variant.filePath,
                filename: r.variant.filename,
                before: r.variant.currentExifDate,
                after: source?.targetDate,
                backupPath: r.isSuccess ? backup?.path : nil,
                succeeded: r.isSuccess)
        }
        if items.contains(where: \.succeeded) {
            history.insert(HistoryBatch(
                strategySummary: defaultStrategy.summary,
                timeZoneIdentifier: defaultTimeZone.identifier,
                items: items), at: 0)
            historyStore.save(history)
        }
    }

    public func rowsNeedingOverwriteConfirmation(target: ApplyTarget) -> [VariantInfo] {
        variants(for: target).filter { v in
            guard let targetDate = v.targetDate, let current = v.info.currentExifDate else { return false }
            return abs(current.timeIntervalSince(targetDate)) >= 1.0 && !v.manuallyEdited
        }.map(\.info)
    }

    public func variants(for target: ApplyTarget) -> [EditableVariant] {
        switch target {
        case .all: return editableVariants
        case .selected: return editableVariants.filter { tableSelection.contains($0.id) }
        }
    }

    public func undoBatch(_ id: UUID, overwriteNewer: Bool) {
        guard let batch = history.first(where: { $0.id == id }) else { return }
        lastUndoHadNewerFiles = false
        for item in batch.items where item.succeeded {
            guard let backupPath = item.backupPath else { continue }
            let backup = URL(fileURLWithPath: backupPath)
            let url = URL(fileURLWithPath: item.filePath)
            let latest = try? BackupStore.latestBackup(for: url)
            let isNewer = latest.map { $0.path != backup.path } ?? false
            if isNewer && !overwriteNewer {
                lastUndoHadNewerFiles = true
                continue
            }
            try? BackupStore.restore(backup: backup, over: url)
        }
        refreshCurrentRows()
    }

    public func restorePrevious(rowID: EditableVariant.ID) {
        guard let row = editableVariants.first(where: { $0.id == rowID }) else { return }
        try? BackupStore.restoreLatest(of: URL(fileURLWithPath: row.info.filePath))
        refreshCurrentRows()
    }

    public func hasBackup(rowID: EditableVariant.ID) -> Bool {
        guard let row = editableVariants.first(where: { $0.id == rowID }) else { return false }
        return (try? BackupStore.latestBackup(for: URL(fileURLWithPath: row.info.filePath))) != nil
    }

    public func pruneBackups() {
        let age = defaults.object(forKey: Self.maxAgeDaysKey) as? Int ?? 30
        let size = defaults.object(forKey: Self.maxSizeMBKey) as? Int ?? 1024
        let dirs = history.flatMap { $0.items }.map {
            BackupStore.backupDirectory(for: URL(fileURLWithPath: $0.filePath))
        }
        try? BackupStore.prune(directories: dirs, maxAgeDays: age, maxSizeMB: size)
    }

    // MARK: - Private

    private func clearActivePresetIfDiverged() {
        guard let id = activePresetID, let p = presets.first(where: { $0.id == id }) else { return }
        let tz = TimeZone(identifier: p.timeZoneIdentifier) ?? .current
        if p.strategy != defaultStrategy || tz.identifier != defaultTimeZone.identifier {
            activePresetID = nil
            presetStore.save(presets: presets, activeID: nil)
        }
    }

    private func mutate(_ id: EditableVariant.ID, _ change: (inout EditableVariant) -> Void) {
        guard let i = editableVariants.firstIndex(where: { $0.id == id }) else { return }
        change(&editableVariants[i])
    }

    private func recomputeAll() {
        editableVariants = AutoFillEngine.apply(
            default: defaultStrategy,
            defaultTimeZone: defaultTimeZone,
            to: editableVariants)
    }

    private func recomputeRow(_ id: EditableVariant.ID) {
        guard let i = editableVariants.firstIndex(where: { $0.id == id }) else { return }
        if case .sequential = (editableVariants[i].strategyOverride ?? defaultStrategy) {
            recomputeAll()
            return
        }
        let updated = AutoFillEngine.apply(
            default: defaultStrategy,
            defaultTimeZone: defaultTimeZone,
            to: [editableVariants[i]])
        editableVariants[i] = updated[0]
    }
}
