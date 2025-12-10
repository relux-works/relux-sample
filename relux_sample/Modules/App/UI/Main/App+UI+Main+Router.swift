import SwiftUI
import NotesReluxInt
import NotesUIAPI

@MainActor
extension SampleApp.UI.Main {
    @ViewBuilder
    static func handleRoute(for page: SampleApp.UI.Main.Model.Page) -> some View {
        let notesProvider = SampleApp.Registry.resolve(NotesUIProviding.self)
        switch page {
            case .main: Container()
            case .account: Account.UI.Container()
            case let .notes(page): notesProvider.view(for: page)
        }
    }
}
