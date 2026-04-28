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

    @Published public private(set) var state: UIState = .loading
    @Published public private(set) var editableVariants: [EditableVariant] = []
    @Published public private(set) var results: [WriteResult] = []
    @Published public var defaultStrategy: AutoFillStrategy = .sameDate(Date())
    @Published public var defaultTimeZone: TimeZone = .current
    @Published public var tableSelection: Set<EditableVariant.ID> = []

    private let bridge: CaptureOneBridging
    private let operation: DateOperation

    public init(bridge: CaptureOneBridging,
                exifWriter: @escaping DateOperation.ExifWrite,
                exifReader: @escaping DateOperation.ExifRead,
                fsWriter:   @escaping DateOperation.FSWrite) {
        self.bridge = bridge
        self.operation = DateOperation(
            bridge: bridge,
            exifWriter: exifWriter,
            exifReader: exifReader,
            fsWriter: fsWriter,
            reloader: { try bridge.reloadMetadata(for: $0) }
        )
    }

    // MARK: - Selection loading

    public func loadSelection() {
        state = .loading
        do {
            let infos = try bridge.readSelection()
            editableVariants = infos.map { EditableVariant(info: $0) }
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

    // MARK: - Strategy / TZ defaults

    public func setDefaultStrategy(_ s: AutoFillStrategy) {
        defaultStrategy = s
        recomputeAll()
    }

    public func setDefaultTimeZone(_ tz: TimeZone) {
        defaultTimeZone = tz
        // TZ doesn't affect target wall-clock unless the strategy parses a date in TZ,
        // so we recompute filename-based rows to honor the new reference TZ.
        recomputeAll()
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

    // MARK: - Apply

    public func apply(target: ApplyTarget, overwritePolicy: DateOperation.OverwritePolicy) {
        let toApply: [EditableVariant]
        switch target {
        case .all:
            toApply = editableVariants
        case .selected:
            toApply = editableVariants.filter { tableSelection.contains($0.id) }
        }
        results = operation.execute(variants: toApply, defaultTimeZone: defaultTimeZone, overwritePolicy: overwritePolicy)
    }

    // MARK: - Private

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
        // Recompute just one row by doing a single-element pass through the engine
        // — keeps the resolution chain in one place. Index is preserved because
        // we replace in-place.
        guard let i = editableVariants.firstIndex(where: { $0.id == id }) else { return }
        let updated = AutoFillEngine.apply(
            default: defaultStrategy,
            defaultTimeZone: defaultTimeZone,
            to: [editableVariants[i]])
        var array = editableVariants
        array[i] = updated[0]
        // For Sequential strategy, single-row recompute is wrong — index in slice was 0, not original.
        if case .sequential = (editableVariants[i].strategyOverride ?? defaultStrategy) {
            recomputeAll()
            return
        }
        editableVariants = array
    }
}
