import SwiftUI
import Relux

// Navigation factory injected from the host application.
private struct NotesNavigationKey: EnvironmentKey {
    static let defaultValue: any NotesUIRouting = StubNotesNavigation()
}

public extension EnvironmentValues {
    var notesNavigation: any NotesUIRouting {
        get { self[NotesNavigationKey.self] }
        set { self[NotesNavigationKey.self] = newValue }
    }
}

// Simple no-op navigation for previews / safety.
struct StubNotesNavigation: NotesUIRouting {
    func push(_ page: Notes.UI.Model.Page) -> any Relux.Action { NoopAction() }
    func set(_ page: Notes.UI.Model.Page) -> any Relux.Action { NoopAction() }
    func pop() -> any Relux.Action { NoopAction() }
}

struct NoopAction: Relux.Action {}
