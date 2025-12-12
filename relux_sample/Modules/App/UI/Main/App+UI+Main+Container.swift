import SwiftUI
import NavigationUI
import SampleAppRoutes

extension SampleApp.UI.Main {
    // ReluxContainer separates the Relux-driven business layer from the SwiftUI view layer.
    struct Container: Relux.UI.Container {
        var body: some View {
            content
                .navBar(trailing: accountBtn)
                .navigationBarHidden(true)
        }

        private var content: some View {
            Page(props: Page.Props())
        }

        private var accountBtn: some View {
            Navigation.UI.NavLink<AppRoute, AppModal, Text>(.account) {
                Text("Account")
            }
            .padding(.horizontal)
        }
    }
}
