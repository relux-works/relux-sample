import SwiftUIRelux

extension Account.UI.Container.Page {
    
    struct Props: ViewProps {

    }

    struct Actions: ViewCallbacks, Equatable {
        let onOpenDebug: ViewCallback<Void>
    }
}
