import AuthUIAPI
import SwiftUI
import SampleAppRoutes

@MainActor
extension SampleApp.UI.Root {
    struct RouterView: View {
        let route: AppRoute
        @Environment(\.notesUIProvider) private var notesProvider

        var body: some View {
            content
        }

        @ViewBuilder
        private var content: some View {
            switch route {
            case .splash:
                SampleApp.UI.Root.Splash(props: Splash.Props())
            case let .auth(page):
                if let router = SampleApp.Registry.optionalResolve(AuthUIProviding.self) {
                    router.view(for: page)
                } else {
                    AnyView(EmptyView())
                }
            case .main, .account, .notes:
                SampleApp.UI.Main.RouterView(route: route)
                    .environment(\.notesUIProvider, notesProvider)
            }
        }
    }
}
