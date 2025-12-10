import SwiftUI
import Relux
import SwiftUIRelux
import NavigationReluxInt

extension Navigation.UI {
    /// Navigation link that dispatches to the central router.
    /// Works from any domain UI without coupling to App target.
    ///
    /// Usage:
    /// ```swift
    /// Navigation.UI.Link(.notes(.create)) {
    ///     Text("Create Note")
    /// }
    /// ```
    public struct Link<Label: View>: View {
        private let destination: Navigation.UI.Model.Destination
        private let label: Label

        @EnvironmentObject private var nav: Relux.UI.ActionRelay<AppNavigation>

        public init(
            _ destination: Navigation.UI.Model.Destination,
            @ViewBuilder label: () -> Label
        ) {
            self.destination = destination
            self.label = label()
        }

        public var body: some View {
            AsyncButton {
                await actions { nav.actions.go(destination) }
            } label: {
                label
            }
        }
    }
}

// MARK: - Convenience Initializers

extension Navigation.UI.Link where Label == Text {
    /// Creates a navigation link with a text label.
    public init(_ title: String, destination: Navigation.UI.Model.Destination) {
        self.destination = destination
        self.label = Text(title)
    }
}

extension Navigation.UI.Link where Label == Image {
    /// Creates a navigation link with a system image.
    public init(systemImage: String, destination: Navigation.UI.Model.Destination) {
        self.destination = destination
        self.label = Image(systemName: systemImage)
    }
}
