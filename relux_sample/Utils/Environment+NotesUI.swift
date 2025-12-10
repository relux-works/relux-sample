import SwiftUI
import NotesUIAPI

// Provider (view factory) environment key
private struct NotesUIProviderKey: EnvironmentKey {
    static let defaultValue: any NotesUIProviding = StubNotesUIProvider()
}

extension EnvironmentValues {
    var notesUIProvider: any NotesUIProviding {
        get { self[NotesUIProviderKey.self] }
        set { self[NotesUIProviderKey.self] = newValue }
    }
}

struct StubNotesUIProvider: NotesUIProviding {
    func view(for page: Notes.UI.Model.Page) -> AnyView { AnyView(EmptyView()) }
}
