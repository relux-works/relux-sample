import SwiftUIRelux

extension Notes.UI.Edit.Container.Page {

    struct Props: ViewProps {
        let note: Note
    }

    struct Actions: ViewCallbacks, Equatable {
        let onSave: ViewInputCallback<Note>
        let onRemove: ViewCallback
    }
}
