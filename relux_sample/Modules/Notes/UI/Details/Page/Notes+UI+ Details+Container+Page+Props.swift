extension Notes.UI.Details.Container.Page {
    struct Props: ViewProps {
        let note: MaybeData<Note?, Err>
    }

    struct Actions: ViewActions {
        let onEdit: @Sendable (Note) async -> Void
    }
}
