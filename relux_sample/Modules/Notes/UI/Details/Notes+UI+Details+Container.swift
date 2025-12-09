import SwiftUI

extension Notes.UI.Details.Container {
    struct Props: ViewProps {
        let id: Notes.UI.State.Note.Id
    }
}

extension Notes.UI.Details {
    // ReluxContainer separates the Relux-driven business layer from the SwiftUI view layer.
    struct Container: Relux.UI.Container {
        typealias Note = Notes.Business.Model.Note

        // In SwiftUI-Relux, the Relux resolver injects all UI states into the root view.
        // If a state conforms to ObservableObject, it’s accessible via @EnvironmentObject.
        // If it’s declared using the @Observable macro, it’s available via @Environment.
        @EnvironmentObject private var notesState: Notes.UI.State

        let props: Props

        var body: some View {
            content
                .task { await loadData() }
        }

        private var content: some View {
            Page(
                props: .init(
                    note: notesState.note(by: props.id)
                ),
                actions: .init(
                    onEdit: ViewInputCallback(openEdit)
                )
            )
        }
    }
}

// reactions
extension Notes.UI.Details.Container {
    private func loadData() async {
        let note = notesState.notes.value?[props.id]
        if note.isNil {
            performAsync { Notes.Business.Effect.obtainNotes }
        }
    }

    private func openEdit(note: Note) async {
        await actions {
            AppRouter.Action.push(.app(page: .notes(.edit(note: note))))
        }
    }
}
