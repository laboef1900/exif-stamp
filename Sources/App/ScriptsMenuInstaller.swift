import Foundation

/// Installs the bundled Capture One Scripts-menu launcher into the user's
/// `~/Library/Scripts/Capture One Scripts/` on first run, so that DMG
/// (drag-install) users get the same Scripts-menu entry that the .pkg
/// installer's postinstall provides.
///
/// Idempotent: only copies when the destination is missing, so a user who
/// chooses to delete the script keeps it deleted on subsequent launches
/// (until they reinstall the app).
enum ScriptsMenuInstaller {
    private static let scriptFilename = "Launch Capture One Date Plugin.scpt"
    private static let captureOneScriptsFolder = "Capture One Scripts"

    static func ensureInstalled() {
        let fm = FileManager.default
        guard let library = fm.urls(for: .libraryDirectory, in: .userDomainMask).first else { return }
        let destDir = library
            .appendingPathComponent("Scripts")
            .appendingPathComponent(captureOneScriptsFolder)
        let dest = destDir.appendingPathComponent(scriptFilename)

        guard !fm.fileExists(atPath: dest.path) else { return }
        guard let src = Bundle.main.url(forResource: "Launch Capture One Date Plugin", withExtension: "scpt") else { return }

        do {
            try fm.createDirectory(at: destDir, withIntermediateDirectories: true)
            try fm.copyItem(at: src, to: dest)
        } catch {
            // Best-effort install. Swallow failures — the app still works
            // without the Scripts-menu entry; the user can copy the file
            // manually from the .app bundle's Resources directory.
        }
    }
}
