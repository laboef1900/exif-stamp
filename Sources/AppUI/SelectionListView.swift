import SwiftUI

struct SelectionListView: View {
    let variants: [VariantInfo]

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f
    }()

    var body: some View {
        Table(variants) {
            TableColumn("Filename") { v in
                Text(v.filename).font(.system(.body, design: .monospaced))
            }
            TableColumn("Current capture date") { v in
                if let d = v.currentExifDate {
                    Text(Self.dateFormatter.string(from: d)).foregroundStyle(.secondary)
                } else {
                    Text("—").foregroundStyle(.tertiary)
                }
            }
        }
        .frame(minHeight: 200)
    }
}

#Preview("Mixed selection") {
    SelectionListView(variants: [
        VariantInfo(filePath: "/p/IMG_001.jpg", filename: "IMG_001.jpg", currentExifDate: nil),
        VariantInfo(filePath: "/p/IMG_002.jpg", filename: "IMG_002.jpg",
                    currentExifDate: Date(timeIntervalSince1970: 1_700_000_000)),
        VariantInfo(filePath: "/p/scan_01.tif", filename: "scan_01.tif", currentExifDate: nil),
    ])
    .padding()
    .frame(width: 600, height: 300)
}

#Preview("Empty") {
    SelectionListView(variants: [])
        .padding()
        .frame(width: 600, height: 300)
}
