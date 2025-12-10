import SwiftUIRelux

extension Notes.UI.Widget.Container.Page {

    struct Props: ViewProps {
        let notes: MaybeData<[[Note]], Err>
    }

    struct Actions: Relux.UI.ViewCallbacks {
        
    }
}
