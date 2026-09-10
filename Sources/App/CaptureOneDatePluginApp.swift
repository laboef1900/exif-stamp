import SwiftUI
import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    weak var vm: RootViewModel?

    func application(_ application: NSApplication, open urls: [URL]) {
        Task { @MainActor in
            self.vm?.openDroppedURLs(urls)
        }
    }
}

@main
struct CaptureOneDatePluginApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var vm = RootViewModel(
        bridge: CaptureOneBridge(),
        exifWriter: { date, tz, url in try ExifWriter.writeCaptureDate(date, timeZone: tz, at: url) },
        exifReader: { url in try ExifWriter.readCaptureDate(at: url) },
        fsWriter:   { date, url in try FileDateWriter.setFileSystemDate(date, at: url) },
        backup:     { url in try BackupStore.captureBackup(of: url) }
    )

    init() {
        ScriptsMenuInstaller.ensureInstalled()
    }

    var body: some Scene {
        WindowGroup {
            ContentView(vm: vm)
                .frame(minWidth: 700, minHeight: 480)
                .onAppear { appDelegate.vm = vm }
        }
        .windowResizability(.contentSize)

        Settings {
            BackupSettingsView()
        }
    }
}
