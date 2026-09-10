import SwiftUI

struct PresetsMenu: View {
    @ObservedObject var vm: RootViewModel
    @Binding var saveName: String
    @Binding var showingSave: Bool
    @Binding var showingManage: Bool

    var body: some View {
        Menu("Presets") {
            ForEach(vm.presets) { p in
                Button {
                    vm.applyPreset(p)
                } label: {
                    if vm.activePresetID == p.id {
                        Label(p.name, systemImage: "checkmark")
                    } else {
                        Text(p.name)
                    }
                }
            }
            Divider()
            Button("Save current as preset…") { showingSave = true }
            Button("Manage presets…") { showingManage = true }
        }
        .sheet(isPresented: $showingSave) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Save preset").font(.headline)
                TextField("Name", text: $saveName)
                HStack {
                    Spacer()
                    Button("Cancel") { showingSave = false }
                    Button("Save") {
                        let name = saveName.trimmingCharacters(in: .whitespacesAndNewlines)
                        if !name.isEmpty { vm.saveCurrentAsPreset(name: name) }
                        saveName = ""
                        showingSave = false
                    }
                    .keyboardShortcut(.defaultAction)
                    .disabled(saveName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .padding(20)
            .frame(width: 360)
        }
        .sheet(isPresented: $showingManage) {
            ManagePresetsSheet(vm: vm, onClose: { showingManage = false })
        }
    }
}

struct ManagePresetsSheet: View {
    @ObservedObject var vm: RootViewModel
    let onClose: () -> Void
    @State private var renameID: UUID?
    @State private var renameText = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Manage presets").font(.headline)
                Spacer()
                Button("Done", action: onClose)
            }
            List {
                ForEach(vm.presets) { p in
                    HStack {
                        if renameID == p.id {
                            TextField("Name", text: $renameText, onCommit: {
                                vm.renamePreset(id: p.id, to: renameText)
                                renameID = nil
                            })
                        } else {
                            Text(p.name)
                            Spacer()
                            Button("Rename") {
                                renameID = p.id
                                renameText = p.name
                            }
                            Button("Delete", role: .destructive) { vm.deletePreset(id: p.id) }
                        }
                    }
                }
                .onMove { vm.movePreset(from: $0, to: $1) }
            }
        }
        .padding(20)
        .frame(minWidth: 420, minHeight: 280)
    }
}
