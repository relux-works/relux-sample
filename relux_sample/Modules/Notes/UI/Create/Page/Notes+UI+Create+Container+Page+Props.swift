extension Notes.UI.Create.Container.Page {
    struct Props: ViewProps {

    }

    struct Actions: ViewActions {
        let onCreate: @Sendable (Note) async -> Void
    }
}
