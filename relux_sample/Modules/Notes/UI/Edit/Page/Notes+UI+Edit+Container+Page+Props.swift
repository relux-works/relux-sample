extension Notes.UI.Edit.Container.Page {
    struct Props: ViewProps {
        let note: Note
    }

    struct Actions: ViewActions {
        let onSave: @Sendable (Note) async -> ()
        let onRemove: @Sendable () async -> ()
    }
}
