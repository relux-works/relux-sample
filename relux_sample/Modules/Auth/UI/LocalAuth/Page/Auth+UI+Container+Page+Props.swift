extension Auth.UI.LocalAuth.Container.Page {
    struct Props: ViewProps {

    }

    struct Actions: ViewActions {
        let onTryLocalAuth: @Sendable () async -> ()
    }
}
