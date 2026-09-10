import SwiftUI
import UniformTypeIdentifiers

struct DropZoneView: View {
    let notice: String?
    let onDrop: ([URL]) -> Void
    @State private var targeted = false

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "square.and.arrow.down")
                .font(.system(size: 36))
                .foregroundStyle(.secondary)
            Text("Drop files").font(.headline)
            Text("Drop images or folders here, or use Finder → Open With.")
                .font(.callout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            if let notice {
                Text(notice).font(.caption).foregroundStyle(.secondary)
            }
        }
        .padding(40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .stroke(targeted ? Color.accentColor : Color.secondary.opacity(0.4),
                        style: StrokeStyle(lineWidth: 2, dash: [8]))
        )
        .padding(20)
        .onDrop(of: [UTType.fileURL], isTargeted: $targeted) { providers in
            DropZoneView.loadURLs(from: providers, then: onDrop)
            return true
        }
    }

    static func loadURLs(from providers: [NSItemProvider], then: @escaping ([URL]) -> Void) -> Bool {
        let group = DispatchGroup()
        let lock = NSLock()
        var urls: [URL] = []
        for provider in providers {
            group.enter()
            provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { item, _ in
                defer { group.leave() }
                let url: URL?
                if let urlItem = item as? URL {
                    url = urlItem
                } else if let data = item as? Data {
                    url = URL(dataRepresentation: data, relativeTo: nil)
                } else if let str = item as? String {
                    url = URL(fileURLWithPath: str)
                } else {
                    url = nil
                }
                if let url {
                    lock.lock()
                    urls.append(url)
                    lock.unlock()
                }
            }
        }
        group.notify(queue: .main) { then(urls) }
        return true
    }
}
