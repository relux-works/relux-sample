import SwiftUI

extension Account.UI.Container {
    struct Page: Relux.UI.View {
        let props: Props
        let actions: Actions
        @State private var confirmLogout = false

        var body: some View {
            Form {
                Section("Local demo session") {
                    Label("On this device", systemImage: "person.crop.circle")
                    Text("Authentication uses your device’s system authentication. Notes stay in memory until the app restarts.")
                        .foregroundStyle(.secondary)
                }
                Section("Developer tools") {
                    AsyncButton(action: actions.onOpenDebug) { Label("About the Architecture", systemImage: "curlybraces") }
                }
                Section {
                    Button("Log Out", role: .destructive) { confirmLogout = true }
                }
            }
            .confirmationDialog("Log out?", isPresented: $confirmLogout, titleVisibility: .visible) {
                Button("Log Out", role: .destructive) { Task { await actions.onLogout() } }
                Button("Cancel", role: .cancel) { }
            }
        }
    }
}
