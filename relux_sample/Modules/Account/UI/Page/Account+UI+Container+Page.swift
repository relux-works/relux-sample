import SwiftUI

extension Account.UI.Container {
    struct Page: Relux.UI.View {
        let props: Props
        let actions: Actions

        var body: some View {
            Form {
                Section("Local sample") {
                    Label("On this device", systemImage: "person.crop.circle")
                    Text("No sign-in is required. Individual locked notes use system device authentication. Notes stay in memory until the app restarts.")
                        .foregroundStyle(.secondary)
                }
                Section("Developer tools") {
                    AsyncButton(action: actions.onOpenDebug) { Label("About the Architecture", systemImage: "curlybraces") }
                }
            }
        }
    }
}
