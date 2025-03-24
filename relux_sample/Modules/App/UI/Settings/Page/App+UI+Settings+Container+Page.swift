import SwiftUI

extension SampleApp.UI.Settings.Container {
    struct Page: View {
        let props: Props
        let actions: Actions

        var body: some View {
            content
        }

        private var content: some View {
            AsyncButton(action: actions.onLogout) {
                Text("Logout")
            }
        }
    }
}
