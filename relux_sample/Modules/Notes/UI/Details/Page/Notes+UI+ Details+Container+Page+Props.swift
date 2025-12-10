import SwiftUIRelux
import NotesReluxInt

extension Notes.UI.Details.Container.Page {

    struct Props: ViewProps {
        let note: MaybeData<Note?, Err>
    }

    struct Actions: Relux.UI.ViewCallbacks {
        let onEdit: ViewInputCallback<Note>
    }
}