import SwiftUI
import Relux
import NavigationReluxInt

extension Navigation.UI {
    /// Back button that navigates to previous screen.
    public struct BackButton<
        Route: Relux.Navigation.PathComponent & Hashable & Sendable,
        Modal: Relux.Navigation.ModalComponent & Hashable & Sendable,
        Label: View
    >: View {
        private let label: Label

        @EnvironmentObject private var nav: Relux.UI.ActionRelay<NavigationActions<Route, Modal>>

        public init(@ViewBuilder label: () -> Label) {
            self.label = label()
        }

        public var body: some View {
            AsyncButton {
                await actions { nav.actions.back() }
            } label: {
                label
            }
        }
    }
}

extension Navigation.UI.BackButton where Label == Image {
    /// Creates a back button with chevron icon.
    public init() {
        self.label = Image(systemName: "chevron.left")
    }
}
