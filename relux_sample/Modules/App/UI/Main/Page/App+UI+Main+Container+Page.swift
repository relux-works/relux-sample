import SwiftUI

extension SampleApp.UI.Main.Container {
    struct Page: Relux.UI.View {
        struct Props: Relux.UI.ViewProps { }
        struct Actions: Relux.UI.ViewCallbacks {
            let onOpenNotes: ViewCallback<Void>
            let onOpenAccount: ViewCallback<Void>
        }
        let props: Props
        let actions: Actions

        var body: some View {
            List {
                Section {
                    AsyncButton(action: actions.onOpenNotes) { Label("Notes", systemImage: "note.text") }
                    AsyncButton(action: actions.onOpenAccount) { Label("Account", systemImage: "person.crop.circle") }
                } header: { Text("Explore") } footer: {
                    Text("Create, edit, and search notes while exploring Relux’s unidirectional data flow.")
                }
                Section("About this demo") {
                    Label("Stored in memory", systemImage: "memorychip")
                    Text("Notes reset when the app restarts. No account server, sync, or network connection is used.")
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Relux Sample")
        }
    }
}
