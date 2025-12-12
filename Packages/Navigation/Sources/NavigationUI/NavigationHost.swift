import SwiftUI
import Relux
import ReluxRouter
import NavigationModels

extension Navigation.UI {
    /// Convenience wrapper for a `NavigationStack` bound to a `ProjectingRouter`.
    ///
    /// Host app defines a concrete `Route` type and provides builders:
    /// ```swift
    /// Navigation.UI.NavigationHost<AppRoute, RootView, ScreenView>(
    ///   root: { RootView() },
    ///   destination: { route in ScreenView(route: route) }
    /// )
    /// ```
    public struct NavigationHost<
        Route: Relux.Navigation.PathComponent & Hashable & Sendable,
        Root: View,
        Destination: View
    >: View {

        @EnvironmentObject private var router: Relux.Navigation.ProjectingRouter<Route>

        private let root: () -> Root
        private let destination: (Route) -> Destination

        public init(
            @ViewBuilder root: @escaping () -> Root,
            @ViewBuilder destination: @escaping (Route) -> Destination
        ) {
            self.root = root
            self.destination = destination
        }

        public var body: some View {
            NavigationStack(path: $router.path) {
                root()
                    .navigationDestination(for: Route.self) { route in
                        destination(route)
                    }
            }
        }
    }
}

