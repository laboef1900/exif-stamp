import Foundation

public struct DroppedFileResolver {
    public static let imageExtensions: Set<String> = [
        "jpg", "jpeg", "tif", "tiff", "heic", "heif", "png", "gif", "bmp",
        "cr2", "cr3", "nef", "nrw", "arw", "srf", "sr2", "raf", "orf", "rw2",
        "dng", "pef", "ptx", "3fr", "fff", "iiq", "rwl", "raw", "srw", "x3f"
    ]

    public struct Outcome: Equatable {
        public let infos: [VariantInfo]
        public let added: Int
        public let unsupported: Int

        public init(infos: [VariantInfo], added: Int, unsupported: Int) {
            self.infos = infos
            self.added = added
            self.unsupported = unsupported
        }
    }

    public static func resolve(_ urls: [URL],
                               existingPaths: Set<String> = [],
                               readDate: (URL) throws -> Date?) -> Outcome {
        var infos: [VariantInfo] = []
        var seen = existingPaths
        var added = 0
        var unsupported = 0

        for url in urls {
            let scoped = url.startAccessingSecurityScopedResource()
            defer { if scoped { url.stopAccessingSecurityScopedResource() } }
            collect(url, seen: &seen, infos: &infos, added: &added, unsupported: &unsupported, readDate: readDate)
        }
        return Outcome(infos: infos, added: added, unsupported: unsupported)
    }

    private static func collect(_ url: URL,
                                seen: inout Set<String>,
                                infos: inout [VariantInfo],
                                added: inout Int,
                                unsupported: inout Int,
                                readDate: (URL) throws -> Date?) {
        let path = url.path
        var isDir: ObjCBool = false
        guard FileManager.default.fileExists(atPath: path, isDirectory: &isDir) else {
            unsupported += 1
            return
        }

        if isDir.boolValue {
            if isSymlink(url) { return }
            let enumerator = FileManager.default.enumerator(
                at: url,
                includingPropertiesForKeys: [.isDirectoryKey, .isSymbolicLinkKey],
                options: [.skipsHiddenFiles, .skipsPackageDescendants]
            )
            while let child = enumerator?.nextObject() as? URL {
                if isSymlink(child) {
                    enumerator?.skipDescendants()
                    continue
                }
                var childDir: ObjCBool = false
                guard FileManager.default.fileExists(atPath: child.path, isDirectory: &childDir) else { continue }
                if childDir.boolValue { continue }
                appendFile(child, seen: &seen, infos: &infos, added: &added, unsupported: &unsupported, readDate: readDate)
            }
            return
        }

        appendFile(url, seen: &seen, infos: &infos, added: &added, unsupported: &unsupported, readDate: readDate)
    }

    private static func appendFile(_ url: URL,
                                   seen: inout Set<String>,
                                   infos: inout [VariantInfo],
                                   added: inout Int,
                                   unsupported: inout Int,
                                   readDate: (URL) throws -> Date?) {
        let ext = url.pathExtension.lowercased()
        guard imageExtensions.contains(ext) else {
            unsupported += 1
            return
        }
        guard seen.insert(url.path).inserted else { return }
        let date = try? readDate(url)
        infos.append(VariantInfo(filePath: url.path, filename: url.lastPathComponent, currentExifDate: date))
        added += 1
    }

    private static func isSymlink(_ url: URL) -> Bool {
        (try? url.resourceValues(forKeys: [.isSymbolicLinkKey]).isSymbolicLink) == true
    }
}
