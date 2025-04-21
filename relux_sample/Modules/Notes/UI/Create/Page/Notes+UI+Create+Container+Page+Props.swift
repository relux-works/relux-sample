extension Notes.UI.Create.Container.Page {
    struct Props: ViewProps {

    }

    struct Actions: ViewActions {
        let onCreate: (Note) async -> Void
    }
}
