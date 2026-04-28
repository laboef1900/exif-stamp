import SwiftUI

struct EmptyStateView: View {
    enum Kind {
        case captureOneNotRunning
        case noDocumentOpen
        case noSelection
        case automationPermissionDenied
        case bridgeError(String)
    }
    let kind: Kind
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon).font(.system(size: 36)).foregroundStyle(.secondary)
            Text(headline).font(.headline)
            Text(detail).font(.callout).foregroundStyle(.secondary).multilineTextAlignment(.center)
            if showsAutomationLink {
                Button("Open Privacy & Security settings") {
                    if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Automation") {
                        NSWorkspace.shared.open(url)
                    }
                }
            }
            Button("Refresh", action: onRetry).keyboardShortcut(.defaultAction)
        }
        .padding(40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var icon: String {
        switch kind {
        case .captureOneNotRunning, .noDocumentOpen: return "photo.on.rectangle.angled"
        case .noSelection: return "checkmark.circle"
        case .automationPermissionDenied: return "lock.shield"
        case .bridgeError: return "exclamationmark.triangle"
        }
    }

    private var headline: String {
        switch kind {
        case .captureOneNotRunning: return "Capture One is not running"
        case .noDocumentOpen: return "No catalog or session open"
        case .noSelection: return "No photos selected"
        case .automationPermissionDenied: return "Automation permission denied"
        case .bridgeError: return "Couldn't talk to Capture One"
        }
    }

    private var detail: String {
        switch kind {
        case .captureOneNotRunning: return "Open Capture One and select photos, then click Refresh."
        case .noDocumentOpen: return "Open a catalog or session in Capture One first."
        case .noSelection: return "Select one or more photos in Capture One, then click Refresh."
        case .automationPermissionDenied: return "Grant this app permission to control Capture One under System Settings → Privacy & Security → Automation."
        case .bridgeError(let s): return s
        }
    }

    private var showsAutomationLink: Bool {
        if case .automationPermissionDenied = kind { return true }
        return false
    }
}

#Preview("Not running") { EmptyStateView(kind: .captureOneNotRunning, onRetry: {}).frame(width: 600, height: 400) }
#Preview("Permission") { EmptyStateView(kind: .automationPermissionDenied, onRetry: {}).frame(width: 600, height: 400) }
