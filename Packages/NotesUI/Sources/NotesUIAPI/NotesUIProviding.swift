import SwiftUI
import NotesReluxInt

@MainActor
public protocol NotesUIProviding: Sendable {
    func view(for page: Notes.UI.Model.Page) -> AnyView
}
