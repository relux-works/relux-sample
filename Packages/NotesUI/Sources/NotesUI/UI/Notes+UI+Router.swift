import SwiftUI
import NotesReluxInt
import NotesUIAPI

public struct NotesUIRouter: NotesUIProviding {
    public init() {}

    @MainActor
    public func view(for page: Notes.UI.Model.Page) -> AnyView {
        switch page {
            case .list:
                AnyView(Notes.UI.List.Container())
            case let .details(id):
                AnyView(Notes.UI.Details.Container(props: .init(id: id)))
            case .create:
                AnyView(Notes.UI.Create.Container())
            case let .edit(note):
                AnyView(Notes.UI.Edit.Container(props: .init(note: note)))
        }
    }
}
