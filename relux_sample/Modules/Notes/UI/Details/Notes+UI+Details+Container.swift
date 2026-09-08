import SwiftUI

extension Notes.UI.Details.Container {
    struct Props: Relux.UI.ViewProps { let id: Notes.UI.State.Note.Id }
}

extension Notes.UI.Details {
    struct Container: Relux.UI.Container {
        typealias Note = Notes.Business.Model.Note
        @EnvironmentObject private var notesState: Notes.UI.State
        @State private var editingNote: Note?
        @State private var errorMessage: String?
        let props: Props

        var body: some View {
            Page(props: .init(note: notesState.note(by: props.id), errorMessage: errorMessage),
                 actions: .init(onEdit: ViewInputCallback(openEdit), onRemove: ViewInputCallback(remove),
                                onReload: ViewCallback(reload)))
                .task { if case .initial = notesState.notes { await reload() } }
                .sheet(item: $editingNote) { note in
                    NavigationStack { Notes.UI.Edit.Container(props: .init(note: note)) }
                }
        }

        private func reload() async { await actions { Notes.Business.Effect.obtainNotes } }
        private func openEdit(_ note: Note) async { editingNote = note }

        private func remove(_ note: Note) async {
            switch await actions(actions: { Notes.Business.Effect.delete(note: note) }) {
            case .success: await actions { AppRouter.Action.removeLast() }
            case .failure: errorMessage = "Couldn’t delete this note. Try again."
            }
        }
    }
}
