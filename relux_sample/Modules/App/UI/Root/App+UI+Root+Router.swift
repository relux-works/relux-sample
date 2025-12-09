import AuthUIAPI
import SwiftUI

@MainActor
extension SampleApp.UI.Root {
    @ViewBuilder
    static func handleRoute(for page: AppPage) -> some View {
        switch page {
            case .splash: SampleApp.UI.Root.Splash()
            case let .auth(page):
                if let router = SampleApp.Registry.optionalResolve(AuthUIProviding.self) {
                    router.view(for: page)
                } else {
                    AnyView(EmptyView())
                }
            case let .app(page): SampleApp.UI.Main.handleRoute(for: page)
        }
    }
}
