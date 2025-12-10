import SwiftUI
import NotesReluxInt
import NotesReluxImpl
import NotesUIAPI
import SwiftUIRelux

extension Notes.UI.List {
    // ReluxContainer separates the Relux-driven business layer from the SwiftUI view layer.
    struct Container: Relux.UI.Container {
        typealias Note = Notes.Business.Model.Note

        // In SwiftUI-Relux, the Relux resolver injects all UI states into the root view.
        // If a state conforms to ObservableObject, it’s accessible via @EnvironmentObject.
        // If it’s declared using the @Observable macro, it’s available via @Environment.
        @EnvironmentObject private var notesState: Notes.UI.State
        @Environment(\.notesNavigation) private var nav

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

// reactions
extension Notes.UI.List.Container {
    private func reloadNotes() async {
        performAsync {
            Notes.Business.Effect.obtainNotes
        }
    }

    private func openCreateNote() async {
        await actions { nav.push(.create) }
    }

    private func remove(_ note: Note) async {
        await actions {
            Notes.Business.Effect.delete(note: note)
        }
    }

    private func openDetails(_ note: Note) async {
        await actions { nav.push(.details(id: note.id)) }
    }
}
