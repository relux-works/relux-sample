import SwiftUI

extension Auth.UI {
    @ViewBuilder
    static func handleRoute(for page: Auth.UI.Model.Page) -> some View {
        switch page {
            case .logoutFlow: Initial.Container()
            case .localAuth: LocalAuth.Container()
        }
    }
}
