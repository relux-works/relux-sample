import SwiftUI

extension Notes.UI.Details.Container {
    struct Props: Relux.UI.ViewProps { let id: Notes.UI.State.Note.Id }
}

extension Notes.UI.Details {
    struct Container: Relux.UI.Container {
        typealias Note = Notes.Business.Model.Note
        @EnvironmentObject private var notesState: Notes.UI.State
        @State private var showEditor = false
        @State private var errorMessage: String?
        let props: Props

        var body: some View {
            Page(props: .init(note: notesState.note(by: props.id), errorMessage: errorMessage),
                 actions: .init(onEdit: ViewInputCallback(openEdit), onRemove: ViewInputCallback(remove),
                                onReload: ViewCallback(reload), onUnlock: ViewCallback(unlock),
                                onProtect: ViewCallback(protect), onRelock: ViewCallback(relock),
                                onRemoveLock: ViewCallback(removeLock)))
                .task { if case .initial = notesState.notes { await reload() } }
                .sheet(isPresented: $showEditor) {
                    NavigationStack { Notes.UI.Edit.Container(props: .init(id: props.id)) }
                }
        }

        private func reload() async { await actions { Notes.Business.Effect.obtainNotes } }
        private func openEdit(_ note: Note) async { if note.editableNote != nil { showEditor = true } }
        private func unlock() async { await protection(.unlock(noteId: props.id)) }
        private func protect() async { await protection(.setProtection(noteId: props.id, protected: true)) }
        private func relock() async { await protection(.relock(noteId: props.id)) }
        private func removeLock() async { await protection(.setProtection(noteId: props.id, protected: false)) }
        private func protection(_ effect: Notes.Business.Effect) async {
            switch await actions(actions: { effect }) {
            case .success: errorMessage = nil
            case .failure: errorMessage = "Couldn’t change access. Unlock this note using device authentication and try again."
            }
        }

        private func remove(_ note: Note) async {
            switch await actions(actions: { Notes.Business.Effect.delete(note: note) }) {
            case .success: await actions { AppRouter.Action.removeLast() }
            case .failure: errorMessage = "Couldn’t delete this note. Try again."
            }
        }
    }
}
