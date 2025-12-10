import SwiftUIRelux
import NotesReluxInt

extension Notes.UI.Create.Container.Page {

    struct Props: ViewProps {

    }

    struct Actions: Relux.UI.ViewCallbacks {
        let onCreate: ViewInputCallback<Note>
    }

}