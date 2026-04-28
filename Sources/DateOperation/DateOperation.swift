import Foundation

/// Orchestrates a date-write batch. Pure-ish: I/O is injected as closures so the type is
/// trivially unit-testable without ImageIO or a running Capture One.
public final class DateOperation {
    public typealias ExifWrite = (_ date: Date, _ url: URL) throws -> Void
    public typealias ExifRead  = (_ url: URL) throws -> Date?
    public typealias FSWrite   = (_ date: Date, _ url: URL) throws -> Void
    public typealias Reload    = (_ paths: [String]) throws -> Void

    public struct Plan: Equatable {
        public let toWriteDirectly: [VariantInfo]
        public let needsOverwriteConfirmation: [VariantInfo]
    }

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

    public func preview(variants: [VariantInfo]) -> Plan {
        var seen = Set<String>()
        let unique = variants.filter { seen.insert($0.filePath).inserted }
        let withoutDate = unique.filter { $0.currentExifDate == nil }
        let withDate = unique.filter { $0.currentExifDate != nil }
        return Plan(toWriteDirectly: withoutDate, needsOverwriteConfirmation: withDate)
    }

    public func execute(variants: [VariantInfo], date: Date, overwritePolicy: OverwritePolicy) -> [WriteResult] {
        let plan = preview(variants: variants)
        let toWrite: [VariantInfo]
        switch overwritePolicy {
        case .skipExisting:
            toWrite = plan.toWriteDirectly
        case .overwriteAll:
            toWrite = plan.toWriteDirectly + plan.needsOverwriteConfirmation
        }

        var results: [WriteResult] = []
        for v in toWrite {
            let url = URL(fileURLWithPath: v.filePath)
            do {
                try exifWriter(date, url)
                do {
                    try fsWriter(date, url)
                    results.append(WriteResult(variant: v, outcome: .success(())))
                } catch let e as DateOperationError {
                    // EXIF wrote but filesystem-date set failed — partial success.
                    results.append(WriteResult(variant: v, outcome: .failure(e)))
                } catch {
                    results.append(WriteResult(variant: v, outcome: .failure(
                        .filesystemDateFailed(path: v.filePath, underlying: error.localizedDescription))))
                }
            } catch let e as DateOperationError {
                results.append(WriteResult(variant: v, outcome: .failure(e)))
            } catch {
                results.append(WriteResult(variant: v, outcome: .failure(
                    .writeFailed(path: v.filePath, underlying: error.localizedDescription))))
            }
        }

        let writtenPaths = results.compactMap { $0.isSuccess ? $0.variant.filePath : nil }
        if !writtenPaths.isEmpty {
            try? reloader(writtenPaths)
        }
        return results
    }
}
