import SwiftUI
import NotesReluxInt
import NotesReluxImpl
import NotesUIAPI
import SwiftUIRelux

extension Notes.UI.Details.Container {
    struct Props: ViewProps {
        let id: Notes.UI.State.Note.Id
    }
}

extension Notes.UI.Details {
    struct Container: Relux.UI.Container {
        typealias Note = Notes.Business.Model.Note

        @EnvironmentObject private var notesState: Notes.UI.State
        @EnvironmentObject private var router: Relux.UI.ActionRelay<any Notes.Business.IRouter>

        let props: Props

        var body: some View {
            content
                .task { await loadData() }
        }

        private var content: some View {
            Page(
                props: Notes.UI.Details.Container.Page.Props(
                    note: notesState.note(by: props.id)
                ),
                actions: Notes.UI.Details.Container.Page.Actions(
                    onEdit: ViewInputCallback(openEdit)
                )
            )
        }
    }
}

extension Notes.UI.Details.Container {
    private func loadData() async {
        let note = notesState.notes.value?[props.id]
        if note.isNil {
            performAsync { Notes.Business.Effect.obtainNotes }
        }
    }

    private func openEdit(note: Note) async {
        await actions { router.actions.pushEdit(note: note) }
    }
}
