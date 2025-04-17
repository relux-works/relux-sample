import SwiftUI

extension Notes.UI.Create {
    struct Container: Relux.UI.Container {
        typealias Note = Notes.Business.Model.Note

        @EnvironmentObject private var notesState: Notes.UI.State

        var body: some View {
            content
        }

        private var content: some View {
            Page(
                props: .init(),
                actions: .init(
                    onCreate: { await create($0) }
                )
            )
        }
    }
}

// reactions
extension Notes.UI.Create.Container {
    private func create(_ note: Note) async {
        await actions {
            Notes.Business.Effect.upsert(note: note)
            AppRouter.Action.removeLast()
        }
    }
}
