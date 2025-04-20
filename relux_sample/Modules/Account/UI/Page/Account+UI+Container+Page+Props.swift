extension Account.UI.Container.Page {
    struct Props: ViewProps {

    }

    struct Actions: ViewActions {
        let onLogout: @Sendable () async -> ()
        let onOpenDebug: @Sendable () async -> ()
    }
}
