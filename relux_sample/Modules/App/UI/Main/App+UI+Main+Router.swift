import SwiftUI
import NotesReluxInt
import NotesUIAPI
import NavigationReluxImpl

@MainActor
extension SampleApp.UI.Main {
    struct RouterView: View {
        let page: InternalPage.AppPage
        @Environment(\.notesUIProvider) private var notesProvider

        var body: some View {
            content
        }

        @ViewBuilder
        private var content: some View {
            switch page {
            case .main:
                Container()
            case .account:
                Account.UI.Container()
            case let .notes(page):
                notesProvider.view(for: page)
            }
        }
    }
}
