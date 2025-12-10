import SwiftUI
import NotesReluxInt
import NotesUIAPI

@MainActor
extension SampleApp.UI.Main {
    struct RouterView: View {
        let page: SampleApp.UI.Main.Model.Page
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
