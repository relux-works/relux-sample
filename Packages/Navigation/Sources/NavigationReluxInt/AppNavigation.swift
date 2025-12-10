import Relux
import NavigationModels

/// Central action factory for app-wide navigation.
/// Auto-injected into SwiftUI environment via `ActionRelay<AppNavigation>`.
///
/// Usage in containers:
/// ```swift
/// @EnvironmentObject private var nav: Relux.UI.ActionRelay<AppNavigation>
///
/// func openNotes() async {
///     await actions { nav.actions.go(.notes(.list)) }
/// }
/// ```
public struct AppNavigation: Relux.ActionProviding {
    public typealias Destination = Navigation.UI.Model.Destination
    public typealias ModalPage = Navigation.Business.Model.ModalPage

    // MARK: - Stack Navigation

    /// Navigate to a destination (push or special handling for back/root).
    public let go: @Sendable (Destination) -> any Relux.Action

    /// Replace entire navigation stack with single destination.
    public let replace: @Sendable (Destination) -> any Relux.Action

    // MARK: - Modal Presentation

    /// Present a modal sheet.
    public let present: @Sendable (ModalPage) -> any Relux.Action

    /// Dismiss current modal.
    public let dismiss: @Sendable () -> any Relux.Action

    // MARK: - Init

    public init(
        go: @escaping @Sendable (Destination) -> any Relux.Action,
        replace: @escaping @Sendable (Destination) -> any Relux.Action,
        present: @escaping @Sendable (ModalPage) -> any Relux.Action,
        dismiss: @escaping @Sendable () -> any Relux.Action
    ) {
        self.go = go
        self.replace = replace
        self.present = present
        self.dismiss = dismiss
    }
}
