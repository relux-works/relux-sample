import Relux

/// Generic action factory for app-wide navigation.
/// Auto-injected into SwiftUI environment via `Relux.UI.ActionRelay`.
///
/// The host app defines its own `Route` and `Modal` types and typealiases:
/// ```swift
/// public typealias AppNavigation = NavigationActions<AppRoute, AppModal>
/// ```
public struct NavigationActions<
    Route: Relux.Navigation.PathComponent,
    Modal: Relux.Navigation.ModalComponent
>: Relux.ActionProviding {

    // MARK: - Stack Navigation

    /// Navigate to a route (push).
    public let go: @Sendable (Route) -> any Relux.Action

    /// Replace entire navigation stack with a single route.
    public let replace: @Sendable (Route) -> any Relux.Action

    /// Pop to previous screen.
    public let back: @Sendable () -> any Relux.Action

    /// Pop to root of current stack.
    public let root: @Sendable () -> any Relux.Action

    // MARK: - Modal Presentation

    /// Present a modal sheet.
    public let present: @Sendable (Modal) -> any Relux.Action

    /// Dismiss current modal.
    public let dismiss: @Sendable () -> any Relux.Action

    public init(
        go: @escaping @Sendable (Route) -> any Relux.Action,
        replace: @escaping @Sendable (Route) -> any Relux.Action,
        back: @escaping @Sendable () -> any Relux.Action,
        root: @escaping @Sendable () -> any Relux.Action,
        present: @escaping @Sendable (Modal) -> any Relux.Action,
        dismiss: @escaping @Sendable () -> any Relux.Action
    ) {
        self.go = go
        self.replace = replace
        self.back = back
        self.root = root
        self.present = present
        self.dismiss = dismiss
    }
}

