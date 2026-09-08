import SwiftUI

extension Notes.UI.List {
    struct Container: Relux.UI.Container {
        typealias Note = Notes.Business.Model.Note
        @EnvironmentObject private var notesState: Notes.UI.State
        @State private var showCreate = false
        @State private var errorMessage: String?

        var body: some View {
            Page(props: .init(notes: notesState.notesGroupedByDay, errorMessage: errorMessage),
                 actions: .init(onReload: ViewCallback(reloadNotes), onCreate: ViewCallback(openCreateNote),
                                onOpen: ViewInputCallback(openNote), onRemove: ViewInputCallback(remove)))
                .task {
                    if case .initial = notesState.notes { await reloadNotes() }
                }
                .sheet(isPresented: $showCreate) {
                    NavigationStack { Notes.UI.Create.Container() }
                }
        }

        private func reloadNotes() async {
            // Await the flow so pull-to-refresh follows the real service lifetime.
            await actions { Notes.Business.Effect.obtainNotes }
        }

        private func openCreateNote() async { showCreate = true }

        private func openNote(_ id: Note.Id) async {
            await actions { AppRouter.Action.push(.app(page: .notes(.details(id: id)))) }
        }

        private func remove(_ note: Note) async {
            switch await actions(actions: { Notes.Business.Effect.delete(note: note) }) {
            case .success: errorMessage = nil
            case .failure: errorMessage = "Couldn’t delete the note. Try again."
            }
        }
    }
}
