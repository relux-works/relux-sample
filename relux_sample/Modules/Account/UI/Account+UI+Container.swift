import SwiftUI

extension Account.UI {
    struct Container: Relux.UI.Container {
        var body: some View {
            content
                .navigationTitle("Account")
                .navigationBarTitleDisplayMode(.inline)
        }

        private var content: some View {
            Page(
                props: .init(),
                actions: .init(
                    onLogout: { await logout() }
                )
            )
        }
    }
}

extension Account.UI.Container {
    private func logout() async {
        await action {
            Auth.Business.Effect.logout
        }
    }
}
