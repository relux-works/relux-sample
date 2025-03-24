extension SampleApp.UI.Settings.Container.Page {
    struct Props: ViewProps {

    }

    struct Actions: ViewActions {
        let onLogout: @Sendable () async -> ()
    }
}
