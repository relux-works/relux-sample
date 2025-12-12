import AuthUIAPI
import SwiftUI
import NavigationReluxInt

@MainActor
extension SampleApp.UI.Root {
    struct RouterView: View {
        let destination: Navigation.UI.Model.Destination
        @Environment(\.notesUIProvider) private var notesProvider

        var body: some View {
            content
        }

        @ViewBuilder
        private var content: some View {
            switch destination {
            case .back, .root:
                EmptyView()
            case .splash:
                SampleApp.UI.Root.Splash(props: Splash.Props())
            case let .auth(page):
                if let router = SampleApp.Registry.optionalResolve(AuthUIProviding.self) {
                    router.view(for: page)
                } else {
                    AnyView(EmptyView())
                }
            case .main, .account, .notes:
                SampleApp.UI.Main.RouterView(destination: destination)
                    .environment(\.notesUIProvider, notesProvider)
            }
        }
    }
}
