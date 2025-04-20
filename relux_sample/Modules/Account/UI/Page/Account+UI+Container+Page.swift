import SwiftUI

extension Account.UI.Container {
    struct Page: View {
        let props: Props
        let actions: Actions

        var body: some View {
            content
        }

        private var content: some View {
            VStack {
                debug
                logout
            }
        }

        private var debug: some View {
            AsyncButton(action: actions.onOpenDebug) {
                Text("Open Debug")
            }
        }

        private var logout: some View {
            AsyncButton(action: actions.onLogout) {
                Text("Logout")
            }
        }
    }
}
