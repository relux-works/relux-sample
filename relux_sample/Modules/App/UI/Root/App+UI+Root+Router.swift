import SwiftUI

@MainActor
extension SampleApp.UI.Root {
    @ViewBuilder
    static func handleRoute(for page: AppPage) -> some View {
        switch page {
        case let .notes(page): Notes.UI.handleRoute(for: page)
        case .settings: SettingsContainer()
        case .account: Account.UI.Container()
        }
    }
}

extension SampleApp.UI.Root {
    struct SettingsContainer: Relux.UI.Container {
        var body: some View {
            SettingsPage(props: .init(), actions: .init(onAccount: ViewCallback(openAccount)))
        }
        private func openAccount() async { await actions { AppRouter.Action.push(.account) } }
    }

    struct SettingsPage: Relux.UI.View {
        struct Props: Relux.UI.ViewProps {}
        struct Actions: Relux.UI.ViewCallbacks { let onAccount: ViewCallback<Void> }
        let props: Props
        let actions: Actions
        var body: some View {
            Form {
                Section {
                    AsyncButton(action: actions.onAccount) { Label("Account", systemImage: "person.crop.circle") }
                }
                Section("Note Protection") {
                    Text("Locked notes use your device’s authentication. Titles remain visible. Notes and locks reset when the app restarts.")
                }
            }
            .navigationTitle("Settings")
        }
    }
}
