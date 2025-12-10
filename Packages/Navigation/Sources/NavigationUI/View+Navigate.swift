import SwiftUI
import NavigationReluxInt

extension View {
    /// Wraps view in a NavigationLink to the given destination.
    ///
    /// Usage:
    /// ```swift
    /// Text("Settings")
    ///     .navigate(to: .account)
    /// ```
    public func navigate(to destination: Navigation.UI.Model.Destination) -> some View {
        Navigation.UI.Link(destination) { self }
    }
}
