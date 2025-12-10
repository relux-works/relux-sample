import SwiftUI
import Relux
import SwiftUIRelux
import NavigationReluxInt

extension Navigation.UI {
    /// Back button that navigates to previous screen.
    public struct BackButton<Label: View>: View {
        private let label: Label

        @EnvironmentObject private var nav: Relux.UI.ActionRelay<AppNavigation>

        public init(@ViewBuilder label: () -> Label) {
            self.label = label()
        }

        public var body: some View {
            AsyncButton {
                await actions { nav.actions.go(.back) }
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
