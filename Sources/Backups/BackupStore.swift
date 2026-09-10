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
        let fm = FileManager.default
        guard let latest = try latestBackup(for: url) else {
            throw DateOperationError.backupFailed(path: url.path, underlying: "No backup found")
        }
        let temp = url.deletingLastPathComponent()
            .appendingPathComponent(".c1dp-restore-\(UUID().uuidString).tmp")
        do {
            try fm.copyItem(at: latest, to: temp)
            _ = try fm.replaceItemAt(url, withItemAt: temp)
        } catch {
            try? fm.removeItem(at: temp)
            throw DateOperationError.backupFailed(path: url.path, underlying: error.localizedDescription)
        }
    }

    public static func latestBackup(for url: URL) throws -> URL? {
        let dir = backupDirectory(for: url)
        let prefix = url.lastPathComponent + "."
        let suffix = ".bak"
        guard let names = try? FileManager.default.contentsOfDirectory(atPath: dir.path) else { return nil }
        let matches = names.filter { $0.hasPrefix(prefix) && $0.hasSuffix(suffix) }.sorted()
        guard let last = matches.last else { return nil }
        return dir.appendingPathComponent(last)
    }

    static func backupDirectory(for url: URL) -> URL {
        url.deletingLastPathComponent().appendingPathComponent(directoryName, isDirectory: true)
    }

    static func backupFilename(for url: URL, timestamp: Date) -> String {
        "\(url.lastPathComponent).\(Int(timestamp.timeIntervalSince1970)).bak"
    }
}
