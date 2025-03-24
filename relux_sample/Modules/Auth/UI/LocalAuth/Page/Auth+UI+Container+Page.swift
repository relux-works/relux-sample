import SwiftUI

extension Auth.UI.LocalAuth.Container {
    struct Page: View {
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
