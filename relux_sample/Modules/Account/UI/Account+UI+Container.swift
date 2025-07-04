import SwiftUI
import Relux

extension Account.UI {
    // ReluxContainer separates the Relux-driven business layer from the SwiftUI view layer.
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
                    onLogout: { await logout() },
                    onOpenDebug: { await openDebug() }
                )
            )
        }
    }
}

extension Account.UI.Container {
    private func openDebug() async {
        await actions {
            ModalRouter.Action.present(page: .debug)
        }
    }

    private func logout() async {
        await actions {
            Auth.Business.Effect.logout
        }
    }
}
