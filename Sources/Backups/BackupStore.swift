import Foundation

/// Per-file backups written next to the original before any EXIF/FS mutation.
/// Layout: `<dir>/.c1dp-backups/<filename>.<unix-timestamp>.bak`
public enum BackupStore {
    public static let directoryName = ".c1dp-backups"

    public static func captureBackup(of url: URL) throws {
        let fm = FileManager.default
        guard fm.fileExists(atPath: url.path) else {
            throw DateOperationError.fileNotFound(path: url.path)
        }
        let dir = backupDirectory(for: url)
        do {
            try fm.createDirectory(at: dir, withIntermediateDirectories: true)
            let dest = dir.appendingPathComponent(backupFilename(for: url, timestamp: Date()))
            try fm.copyItem(at: url, to: dest)
        } catch let e as DateOperationError {
            throw e
        } catch {
            throw DateOperationError.backupFailed(path: url.path, underlying: error.localizedDescription)
        }
    }

    public static func restoreLatest(of url: URL) throws {
        guard let latest = try latestBackup(for: url) else {
            throw DateOperationError.restoreFailed(path: url.path, underlying: "No backup found")
        }
        try restore(backup: latest, over: url)
    }

    public static func restore(backup: URL, over url: URL) throws {
        let fm = FileManager.default
        guard fm.fileExists(atPath: backup.path) else {
            throw DateOperationError.restoreFailed(path: url.path, underlying: "Backup missing")
        }
        let temp = url.deletingLastPathComponent()
            .appendingPathComponent(".c1dp-restore-\(UUID().uuidString).tmp")
        do {
            try fm.copyItem(at: backup, to: temp)
            _ = try fm.replaceItemAt(url, withItemAt: temp)
        } catch {
            try? fm.removeItem(at: temp)
            throw DateOperationError.restoreFailed(path: url.path, underlying: error.localizedDescription)
        }
    }

    public static func latestBackup(for url: URL) throws -> URL? {
        try backups(for: url).max(by: { timestamp(of: $0) < timestamp(of: $1) })
    }

    public static func backups(for url: URL) throws -> [URL] {
        let dir = backupDirectory(for: url)
        let prefix = url.lastPathComponent + "."
        guard let names = try? FileManager.default.contentsOfDirectory(atPath: dir.path) else { return [] }
        return names
            .filter { $0.hasPrefix(prefix) && $0.hasSuffix(".bak") }
            .map { dir.appendingPathComponent($0) }
    }

    /// Deletes backups older than `maxAgeDays`, then oldest files until each
    /// `.c1dp-backups` directory is under `maxSizeMB`.
    public static func prune(directories: [URL],
                             maxAgeDays: Int,
                             maxSizeMB: Int,
                             now: Date = Date()) throws {
        let fm = FileManager.default
        let ageCutoff = now.addingTimeInterval(-TimeInterval(maxAgeDays * 24 * 3600))
        let sizeCap = maxSizeMB * 1024 * 1024
        let unique = Array(Set(directories.map(\.path))).map { URL(fileURLWithPath: $0) }

        for dir in unique {
            guard let names = try? fm.contentsOfDirectory(atPath: dir.path) else { continue }
            var files: [(url: URL, date: Date, size: Int)] = []
            for name in names where name.hasSuffix(".bak") {
                let url = dir.appendingPathComponent(name)
                let attrs = try? fm.attributesOfItem(atPath: url.path)
                let size = (attrs?[.size] as? NSNumber)?.intValue ?? 0
                let date = Date(timeIntervalSince1970: timestamp(of: url))
                if date < ageCutoff {
                    try? fm.removeItem(at: url)
                } else {
                    files.append((url, date, size))
                }
            }
            files.sort { $0.date < $1.date }
            var total = files.reduce(0) { $0 + $1.size }
            while total > sizeCap, let oldest = files.first {
                try? fm.removeItem(at: oldest.url)
                total -= oldest.size
                files.removeFirst()
            }
        }
    }

    static func backupDirectory(for url: URL) -> URL {
        url.deletingLastPathComponent().appendingPathComponent(directoryName, isDirectory: true)
    }

    static func timestamp(of backup: URL) -> TimeInterval {
        let name = backup.lastPathComponent
        guard name.hasSuffix(".bak") else { return 0 }
        let stem = String(name.dropLast(4)) // strip .bak
        let parts = stem.split(separator: ".")
        if let last = parts.last, let n = TimeInterval(last) { return n }
        return 0
    }

    static func backupFilename(for url: URL, timestamp: Date) -> String {
        "\(url.lastPathComponent).\(Int(timestamp.timeIntervalSince1970)).bak"
    }
}
