import SwiftUIRelux

extension Notes.UI.Details.Container.Page {

    struct Props: ViewProps {
        let note: MaybeData<Note?, Err>
    }

    struct Actions: ViewCallbacks, Equatable {
        let onEdit: ViewInputCallback<Note>
    }
}
