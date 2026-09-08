import SwiftUIRelux

extension Notes.UI.Edit.Container.Page {
    struct Props: Relux.UI.ViewProps {
        let note: Note
        var errorMessage: String? = nil
    }
    struct Actions: Relux.UI.ViewCallbacks {
        let onSave: ViewInputCallback<Note>
        let onCancel: ViewCallback<Void>
    }
}
