import AuthReluxInt
import SwiftUI
import SwiftUIRelux

extension Auth.UI.LocalAuth.Container {
    struct Page: Relux.UI.View {
        let props: Props
        let actions: Actions

        var body: some View {
            content
        }

        private var content: some View {
            VStack {
                Text("Local auth page")

                AsyncButton(action: actions.onTryLocalAuth) {
                    Text("Authorize")
                }
            }
        }
    }
}
