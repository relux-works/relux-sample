import SwiftUIRelux

extension Account.UI.Container.Page {
    
    struct Props: ViewProps {

    }

    struct Actions: ViewCallbacks, Equatable {
        let onLogout: ViewCallback
        let onOpenDebug: ViewCallback
    }
}
