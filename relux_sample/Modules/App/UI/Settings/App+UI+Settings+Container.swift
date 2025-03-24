import SwiftUI

extension SampleApp.UI.Settings {
    struct Container: Relux.UI.Container {
        var body: some View {
            content
                .navigationTitle("Settings")
                .navigationBarTitleDisplayMode(.inline)
        }

        private var content: some View {
            Page(
                props: .init(),
                actions: .init(
                    onLogout: logout
                )
            )
        }
    }
}

extension SampleApp.UI.Settings.Container {
    private func logout() async {
        await action {
            Auth.Business.Effect.logout
        }
    }
}
