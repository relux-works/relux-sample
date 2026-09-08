import SwiftUIRelux

extension Notes.UI.Create.Container.Page {
    struct Props: Relux.UI.ViewProps {

        var errorMessage: String? = nil
    }
    struct Actions: Relux.UI.ViewCallbacks {
        let onCreate: ViewInputCallback<Note>
        let onCancel: ViewCallback<Void>
    }
}
