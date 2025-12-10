import AuthUIAPI
import SwiftUI

@MainActor
extension SampleApp.UI.Root {
    struct RouterView: View {
        let page: AppPage
        @Environment(\.notesUIProvider) private var notesProvider

        var body: some View {
            content
        }

        @ViewBuilder
        private var content: some View {
            switch page {
                case .splash:
                    SampleApp.UI.Root.Splash(props: Splash.Props())
                case let .auth(page):
                    if let router = SampleApp.Registry.optionalResolve(AuthUIProviding.self) {
                        router.view(for: page)
                    } else {
                        AnyView(EmptyView())
                    }
                case let .app(page):
                    SampleApp.UI.Main.RouterView(page: page)
                        .environment(\.notesUIProvider, notesProvider)
            }
        }
    }
}
