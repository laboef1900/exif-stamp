import Foundation

/// Writes capture dates into proprietary RAW by shelling out to ExifTool.
/// ImageIO must not rewrite RAW — that strips maker notes.
public enum RawExifTool {
    public static let extensions: Set<String> = [
        "cr2", "cr3", "nef", "nrw", "arw", "srf", "sr2", "raf", "orf", "rw2",
        "dng", "pef", "ptx", "3fr", "fff", "iiq", "rwl", "raw", "srw", "x3f"
    ]

    /// Overridable for tests.
    public static var locateExecutable: () -> String? = defaultLocate

    public static func isRaw(at url: URL) -> Bool {
        extensions.contains(url.pathExtension.lowercased())
    }

    public static func writeCaptureDate(_ date: Date, timeZone: TimeZone, at url: URL) throws {
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw DateOperationError.fileNotFound(path: url.path)
        }
        guard let exe = locateExecutable() else {
            throw DateOperationError.exifToolMissing(path: url.path)
        }
        let status = try run(executable: exe, arguments: writeArguments(date: date, timeZone: timeZone, file: url.path))
        guard status == 0 else {
            throw DateOperationError.writeFailed(path: url.path, underlying: "ExifTool exited \(status)")
        }
    }

    public static func readCaptureDate(at url: URL) throws -> Date? {
        guard let exe = locateExecutable() else { return nil }
        let pipe = Pipe()
        let proc = Process()
        proc.executableURL = URL(fileURLWithPath: exe)
        proc.arguments = ["-s3", "-DateTimeOriginal", "-OffsetTimeOriginal", url.path]
        proc.standardOutput = pipe
        proc.standardError = Pipe()
        try proc.run()
        proc.waitUntilExit()
        guard proc.terminationStatus == 0 else { return nil }
        let text = String(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8)?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let lines = text.split(whereSeparator: \.isNewline).map(String.init)
        guard let first = lines.first, !first.isEmpty else { return nil }
        let offset = lines.count > 1 ? lines[1] : nil
        let tz: TimeZone
        if let offset, let parsed = ExifDateFormatter.timeZone(fromOffset: offset) {
            tz = parsed
        } else {
            tz = TimeZone(secondsFromGMT: 0)!
        }
        return ExifDateFormatter.date(from: first, timeZone: tz)
    }

    static func writeArguments(date: Date, timeZone: TimeZone, file: String) -> [String] {
        let formatted = ExifDateFormatter.string(from: date, timeZone: timeZone)
        let offset = ExifWriter.formatOffset(timeZone, for: date)
        return [
            "-overwrite_original",
            "-P",
            "-DateTimeOriginal=\(formatted)",
            "-CreateDate=\(formatted)",
            "-ModifyDate=\(formatted)",
            "-OffsetTimeOriginal=\(offset)",
            "-OffsetTimeDigitized=\(offset)",
            file
        ]
    }

    static func defaultLocate() -> String? {
        let candidates = [
            "/opt/homebrew/bin/exiftool",
            "/usr/local/bin/exiftool",
            "/usr/bin/exiftool"
        ]
        let fm = FileManager.default
        if let hit = candidates.first(where: { fm.isExecutableFile(atPath: $0) }) {
            return hit
        }
        guard let path = ProcessInfo.processInfo.environment["PATH"] else { return nil }
        for dir in path.split(separator: ":") {
            let candidate = URL(fileURLWithPath: String(dir)).appendingPathComponent("exiftool").path
            if fm.isExecutableFile(atPath: candidate) { return candidate }
        }
        return nil
    }

    private static func run(executable: String, arguments: [String]) throws -> Int32 {
        let proc = Process()
        proc.executableURL = URL(fileURLWithPath: executable)
        proc.arguments = arguments
        proc.standardOutput = Pipe()
        proc.standardError = Pipe()
        try proc.run()
        proc.waitUntilExit()
        return proc.terminationStatus
    }
}
