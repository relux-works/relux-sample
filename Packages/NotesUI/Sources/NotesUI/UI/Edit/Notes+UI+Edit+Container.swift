import SwiftUI
import NotesReluxInt
import NotesUIAPI
import SwiftUIRelux

extension Notes.UI.Edit.Container {
    struct Props: ViewProps {
        let note: Notes.Business.Model.Note
    }
}

extension Notes.UI.Edit {
    // ReluxContainer separates the Relux-driven business layer from the SwiftUI view layer.
    struct Container: Relux.UI.Container {
        typealias Note = Notes.Business.Model.Note

        let props: Props

        var body: some View {
            content
        }

        private var content: some View {
            Page(
                props: .init(
                    note: props.note
                ),
                actions: .init(
                    onSave: ViewInputCallback(upsert),
                    onRemove: ViewCallback { await remove(props.note) }
                )
            )
        }
    }
}

// reactions
extension Notes.UI.Edit.Container {
    private func upsert(_ note: Note) async {
        guard let router = NotesUIRoutingRegistry.router else { return }
        await actions {
            Notes.Business.Effect.upsert(note: note)
            router.pop()
        }
    }

    private func remove(_ note: Note) async {
        guard let router = NotesUIRoutingRegistry.router else { return }
        await actions {
            Notes.Business.Effect.delete(note: note)
            router.pop()
        }
    }
}
