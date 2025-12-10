import SwiftUIRelux

extension Notes.UI.List.Container.Page {

    struct Props: ViewProps {
        let notes: MaybeData<[[Note]], Err>
    }

    struct Actions: Relux.UI.ViewCallbacks {
        let onReload: ViewCallback<Void>
        let onCreate: ViewCallback<Void>
        let onRemove: ViewInputCallback<Note>
    }
}
