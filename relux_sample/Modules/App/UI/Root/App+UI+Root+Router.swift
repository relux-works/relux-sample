import SwiftUI

extension SampleApp.UI.Root {
    @ViewBuilder
    static func handleRoute(for page: AppPage) -> some View {
        switch page {
            case .splash: SampleApp.UI.Root.Splash()
            case let .auth(page): Auth.UI.handleRoute(for: page)
            case let .app(page): SampleApp.UI.Main.handleRoute(for: page)
        }
    }
}
