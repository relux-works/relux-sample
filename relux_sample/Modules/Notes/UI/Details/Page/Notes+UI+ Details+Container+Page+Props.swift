import SwiftUIRelux

extension Notes.UI.Details.Container.Page {
    struct Props: Relux.UI.ViewProps {
        let note: MaybeData<Note?, Err>
        var errorMessage: String? = nil
    }
    struct Actions: Relux.UI.ViewCallbacks {
        let onEdit: ViewInputCallback<Note>
        let onRemove: ViewInputCallback<Note>
        let onReload: ViewCallback<Void>
    }
}
