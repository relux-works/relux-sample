extension Notes.UI.List.Container.Page {
    struct Props: ViewProps {
        let notes: MaybeData<[[Note]], Err>
    }

    struct Actions: ViewActions {
        let onReload: @Sendable () async -> Void
        let onCreate: @Sendable () async -> Void
        let onRemove: @Sendable (Note) async -> Void
    }
}
