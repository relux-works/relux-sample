import SwiftUI
import NotesReluxInt
import NotesReluxImpl
import NotesUIAPI
import SwiftUIRelux


extension Notes.UI.List {
    struct Container: Relux.UI.Container {
        typealias Note = Notes.Business.Model.Note

        @EnvironmentObject private var notesState: Notes.UI.State
        @EnvironmentObject private var router: Relux.UI.ActionRelay<any Notes.Business.IRouter>

        var body: some View {
            content
        }

        private var content: some View {
            Page(
                props: .init(
                    notes: notesState.notesGroupedByDay
                ),
                actions: .init(
                    onReload: ViewCallback(reloadNotes),
                    onCreate: ViewCallback(openCreateNote),
                    onRemove: ViewInputCallback(remove),
                    onOpenDetails: ViewInputCallback(openDetails)
                )
            )
        }
    }
}

extension Notes.UI.List.Container {
    private func reloadNotes() async {
        performAsync {
            Notes.Business.Effect.obtainNotes
        }
    }

    private func openCreateNote() async {
        await actions { router.actions.pushCreate() }
    }

    private func remove(_ note: Note) async {
        await actions {
            Notes.Business.Effect.delete(note: note)
        }
    }

    private func openDetails(_ note: Note) async {
        await actions { router.actions.pushDetails(id: note.id) }
    }
}
