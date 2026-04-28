import SwiftUI

struct ContentView: View {
    @ObservedObject var vm: RootViewModel
    @State private var showingOverwriteSheet = false
    @State private var showingResults = false

    var body: some View {
        VStack(spacing: 0) {
            switch vm.state {
            case .loading:
                ProgressView().padding()
            case .captureOneNotRunning:
                EmptyStateView(kind: .captureOneNotRunning) { vm.loadSelection() }
            case .noDocumentOpen:
                EmptyStateView(kind: .noDocumentOpen) { vm.loadSelection() }
            case .automationPermissionDenied:
                EmptyStateView(kind: .automationPermissionDenied) { vm.loadSelection() }
            case .bridgeError(let s):
                EmptyStateView(kind: .bridgeError(s)) { vm.loadSelection() }
            case .ready:
                if vm.variants.isEmpty {
                    EmptyStateView(kind: .noSelection) { vm.loadSelection() }
                } else {
                    readyContent
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button { vm.loadSelection() } label: {
                    Label("Refresh", systemImage: "arrow.clockwise")
                }
            }
        }
        .sheet(isPresented: $showingOverwriteSheet) {
            OverwriteWarningSheet(
                datedVariants: vm.preview().needsOverwriteConfirmation,
                onSkip: {
                    showingOverwriteSheet = false
                    vm.apply(date: vm.selectedDate, overwritePolicy: .skipExisting)
                    showingResults = true
                },
                onOverwrite: {
                    showingOverwriteSheet = false
                    vm.apply(date: vm.selectedDate, overwritePolicy: .overwriteAll)
                    showingResults = true
                },
                onCancel: { showingOverwriteSheet = false }
            )
        }
        .sheet(isPresented: $showingResults) {
            ResultsView(results: vm.results) {
                showingResults = false
                vm.loadSelection()
            }
        }
        .onAppear { vm.loadSelection() }
    }

    @ViewBuilder
    private var readyContent: some View {
        let plan = vm.preview()
        VStack(spacing: 12) {
            SelectionListView(variants: vm.variants)
            Divider()
            DatePickerSection(
                date: $vm.selectedDate,
                undatedCount: plan.toWriteDirectly.count,
                datedCount: plan.needsOverwriteConfirmation.count,
                onApply: {
                    if plan.needsOverwriteConfirmation.isEmpty {
                        vm.apply(date: vm.selectedDate, overwritePolicy: .skipExisting)
                        showingResults = true
                    } else {
                        showingOverwriteSheet = true
                    }
                }
            )
            .padding(.horizontal)
            .padding(.bottom)
        }
    }
}
