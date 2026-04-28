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
}
