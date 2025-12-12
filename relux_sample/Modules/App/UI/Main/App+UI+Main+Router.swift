import SwiftUI
import NotesReluxInt
import NotesUIAPI
import NavigationReluxInt

@MainActor
extension SampleApp.UI.Main {
    struct RouterView: View {
        let destination: Navigation.UI.Model.Destination
        @Environment(\.notesUIProvider) private var notesProvider

        var body: some View {
            content
        }

        @ViewBuilder
        private var content: some View {
            switch destination {
            case .main:
                Container()
            case .account:
                Account.UI.Container()
            case let .notes(page):
                notesProvider.view(for: page)
            default:
                EmptyView()
            }
        }
    }
}
