import SwiftUIRelux
import NotesReluxInt

extension Notes.UI.Widget.Container.Page {

    struct Props: ViewProps {
        let notes: MaybeData<[[Note]], Err>
    }

    struct Actions: Relux.UI.ViewCallbacks {
        let onOpenList: ViewCallback<Void>
    }
}
