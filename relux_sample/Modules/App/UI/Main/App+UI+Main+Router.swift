import SwiftUI
import NotesReluxInt
import NotesUIAPI
import SampleAppRoutes

@MainActor
extension SampleApp.UI.Main {
    struct RouterView: View {
        let route: AppRoute
        @Environment(\.notesUIProvider) private var notesProvider

        var body: some View {
            content
        }

        @ViewBuilder
        private var content: some View {
            switch route {
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
