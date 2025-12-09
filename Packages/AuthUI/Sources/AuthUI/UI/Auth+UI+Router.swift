import Auth
import AuthUIAPI
import SwiftUI

public struct AuthUIRouter: AuthUIProviding {
    public init() {}

    @MainActor
    public func view(for page: Auth.UI.Model.Page) -> AnyView {
        switch page {
            case .logoutFlow:
                AnyView(Auth.UI.Initial.Container())
            case .localAuth:
                AnyView(Auth.UI.LocalAuth.Container())
        }
    }
}
