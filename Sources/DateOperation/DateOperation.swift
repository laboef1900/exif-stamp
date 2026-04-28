import Foundation

/// Orchestrates a per-row date-write batch. I/O is injected as closures so the
/// orchestrator is unit-testable without ImageIO or a running Capture One.
public final class DateOperation {
    public typealias ExifWrite = (_ date: Date, _ timeZone: TimeZone, _ url: URL) throws -> Void
    public typealias ExifRead  = (_ url: URL) throws -> Date?
    public typealias FSWrite   = (_ date: Date, _ url: URL) throws -> Void
    public typealias Reload    = (_ paths: [String]) throws -> Void

    public enum OverwritePolicy { case skipExisting, overwriteAll }

    private let bridge: CaptureOneBridging
    private let exifWriter: ExifWrite
    private let exifReader: ExifRead
    private let fsWriter: FSWrite
    private let reloader: Reload

    public init(bridge: CaptureOneBridging,
                exifWriter: @escaping ExifWrite,
                exifReader: @escaping ExifRead,
                fsWriter: @escaping FSWrite,
                reloader: @escaping Reload) {
        self.bridge = bridge
        self.exifWriter = exifWriter
        self.exifReader = exifReader
        self.fsWriter = fsWriter
        self.reloader = reloader
    }

    public func execute(variants: [EditableVariant],
                        defaultTimeZone: TimeZone,
                        overwritePolicy: OverwritePolicy) -> [WriteResult] {
        var results: [WriteResult] = []
        for v in variants {
            guard let target = v.targetDate else { continue }
            // Skip rows whose target equals current and policy says skip.
            if overwritePolicy == .skipExisting,
               let current = v.info.currentExifDate,
               abs(current.timeIntervalSince(target)) < 1.0 {
                continue
            }
            let tz = v.timeZoneOverride ?? defaultTimeZone
            let url = URL(fileURLWithPath: v.info.filePath)
            do {
                try exifWriter(target, tz, url)
                do {
                    try fsWriter(target, url)
                    results.append(WriteResult(variant: v.info, outcome: .success(())))
                } catch let e as DateOperationError {
                    results.append(WriteResult(variant: v.info, outcome: .failure(e)))
                } catch {
                    results.append(WriteResult(variant: v.info, outcome: .failure(
                        .filesystemDateFailed(path: v.info.filePath, underlying: error.localizedDescription))))
                }
            } catch let e as DateOperationError {
                results.append(WriteResult(variant: v.info, outcome: .failure(e)))
            } catch {
                results.append(WriteResult(variant: v.info, outcome: .failure(
                    .writeFailed(path: v.info.filePath, underlying: error.localizedDescription))))
            }
        }
        let writtenPaths = results.compactMap { $0.isSuccess ? $0.variant.filePath : nil }
        if !writtenPaths.isEmpty {
            try? reloader(writtenPaths)
        }
        return results
    }
}
