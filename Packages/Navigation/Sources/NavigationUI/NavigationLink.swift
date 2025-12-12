import SwiftUI
import Relux
import NavigationReluxInt

extension Navigation.UI {
    /// Navigation link that dispatches to the central router.
    ///
    /// Host app should define:
    /// ```swift
    /// typealias AppNavLink<Label: View> = Navigation.UI.NavLink<AppRoute, AppModal, Label>
    /// ```
    public struct NavLink<
        Route: Relux.Navigation.PathComponent & Hashable & Sendable,
        Modal: Relux.Navigation.ModalComponent & Hashable & Sendable,
        Label: View
    >: View {

        private let route: Route
        private let label: Label

        @EnvironmentObject private var nav: Relux.UI.ActionRelay<NavigationActions<Route, Modal>>

        public init(
            _ route: Route,
            @ViewBuilder label: () -> Label
        ) {
            self.route = route
            self.label = label()
        }

        public var body: some View {
            AsyncButton {
                await actions { nav.actions.go(route) }
            } label: {
                label
            }
        }
    }
}

// MARK: - Convenience Initializers

extension Navigation.UI.NavLink where Label == Text {
    public init(_ title: String, route: Route) {
        self.route = route
        self.label = Text(title)
    }
}

extension Navigation.UI.NavLink where Label == Image {
    public init(systemImage: String, route: Route) {
        self.route = route
        self.label = Image(systemName: systemImage)
    }
}
