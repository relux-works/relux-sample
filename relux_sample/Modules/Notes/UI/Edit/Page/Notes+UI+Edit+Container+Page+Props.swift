import SwiftUIRelux

extension Notes.UI.Edit.Container.Page {

    struct Props: ViewProps {
        let note: Note
    }

    struct Actions: Relux.UI.ViewCallbacks {
        let onSave: ViewInputCallback<Note>
        let onRemove: ViewCallback<Void>
    }
}
