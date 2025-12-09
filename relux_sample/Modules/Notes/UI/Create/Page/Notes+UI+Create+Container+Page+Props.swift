import SwiftUIRelux

extension Notes.UI.Create.Container.Page {

    struct Props: ViewProps {

    }

    struct Actions: ViewCallbacks, Equatable {
        let onCreate: ViewInputCallback<Note>
    }
}
