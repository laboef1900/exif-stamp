import Foundation
import Combine

// Uses ObservableObject (Combine) rather than @Observable (Observation framework)
// because the deployment target is macOS 13 and @Observable requires macOS 14+.
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

    @Published public private(set) var state: UIState = .loading
    @Published public private(set) var variants: [VariantInfo] = []
    @Published public private(set) var results: [WriteResult] = []
    @Published public var selectedDate: Date = Date()

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

    public func loadSelection() {
        state = .loading
        do {
            variants = try bridge.readSelection()
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

    public func preview() -> DateOperation.Plan {
        operation.preview(variants: variants)
    }

    public func apply(date: Date, overwritePolicy: DateOperation.OverwritePolicy) {
        results = operation.execute(variants: variants, date: date, overwritePolicy: overwritePolicy)
    }
}
