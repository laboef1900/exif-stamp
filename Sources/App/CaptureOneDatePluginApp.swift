import SwiftUI

@main
struct CaptureOneDatePluginApp: App {
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
        }
        .windowResizability(.contentSize)
    }
}
