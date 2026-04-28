import SwiftUI

struct ContentView: View {
    @ObservedObject var vm: RootViewModel
    var body: some View {
        Text("v1.1.0 Foundation in progress — Task 17 wires this up")
            .frame(minWidth: 700, minHeight: 480)
            .padding()
    }
}
