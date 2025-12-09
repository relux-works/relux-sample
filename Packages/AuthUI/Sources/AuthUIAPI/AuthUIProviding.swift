import Auth
import SwiftUI

public protocol AuthUIProviding: Sendable {
    @MainActor
    func view(for page: Auth.UI.Model.Page) -> AnyView
}
