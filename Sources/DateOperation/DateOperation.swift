import Foundation

/// Orchestrates a per-row date-write batch. I/O is injected as closures so the
/// orchestrator is unit-testable without ImageIO or a running Capture One.
public final class DateOperation {
    public typealias ExifWrite = (_ date: Date, _ timeZone: TimeZone, _ url: URL) throws -> Void
    public typealias ExifRead  = (_ url: URL) throws -> Date?
    public typealias FSWrite   = (_ date: Date, _ url: URL) throws -> Void
    public typealias Reload    = (_ paths: [String]) throws -> Void
    public typealias Backup    = (_ url: URL) throws -> Void

    public enum OverwritePolicy { case skipExisting, overwriteAll }

    private let exifWriter: ExifWrite
    private let fsWriter: FSWrite
    private let reloader: Reload
    private let backup: Backup

    public init(exifWriter: @escaping ExifWrite,
                fsWriter: @escaping FSWrite,
                reloader: @escaping Reload,
                backup: @escaping Backup) {
        self.exifWriter = exifWriter
        self.fsWriter = fsWriter
        self.reloader = reloader
        self.backup = backup
    }

    public func execute(variants: [EditableVariant],
                        defaultTimeZone: TimeZone,
                        overwritePolicy: OverwritePolicy) -> [WriteResult] {
        var results: [WriteResult] = []
        var seen = Set<String>()
        for v in variants {
            guard seen.insert(v.info.filePath).inserted else { continue }
            guard let target = v.targetDate else { continue }
            // skipExisting: skip dated rows (the overwrite sheet's "Skip those"),
            // except manually edited rows — those skipped the warning by intent.
            // Also skip when current already matches target (no-op write).
            if overwritePolicy == .skipExisting, let current = v.info.currentExifDate {
                if abs(current.timeIntervalSince(target)) < 1.0 { continue }
                if !v.manuallyEdited { continue }
            }
            let tz = v.timeZoneOverride ?? defaultTimeZone
            let url = URL(fileURLWithPath: v.info.filePath)
            do {
                try backup(url)
            } catch let e as DateOperationError {
                results.append(WriteResult(variant: v.info, outcome: .failure(e)))
                continue
            } catch {
                results.append(WriteResult(variant: v.info, outcome: .failure(
                    .backupFailed(path: v.info.filePath, underlying: error.localizedDescription))))
                continue
            }
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
            do {
                try reloader(writtenPaths)
            } catch {
                results.append(WriteResult(
                    variant: VariantInfo(
                        filePath: writtenPaths[0],
                        filename: "Capture One metadata reload",
                        currentExifDate: nil),
                    outcome: .failure(.metadataReloadFailed(underlying: error.localizedDescription))))
            }
        }
        return results
    }
}
