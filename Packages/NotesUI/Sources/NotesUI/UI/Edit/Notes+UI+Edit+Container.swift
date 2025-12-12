import SwiftUI
import NotesReluxInt
import NotesUIAPI
import Relux
import SwiftUIRelux

extension Notes.UI.Edit.Container {
    struct Props: ViewProps {
        let note: Notes.Business.Model.Note
    }
}

extension Notes.UI.Edit {
    struct Container: Relux.UI.Container {
        typealias Note = Notes.Business.Model.Note

        let props: Props
        @EnvironmentObject private var router: Relux.UI.ActionRelay<any Notes.Business.IRouter>

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

extension Notes.UI.Edit.Container {
    private func upsert(_ note: Note) async {
        await actions {
            Notes.Business.Effect.upsert(note: note)
            router.actions.back()
        }
    }

    private func remove(_ note: Note) async {
        await actions {
            Notes.Business.Effect.delete(note: note)
            router.actions.back()
        }
    }
}
