import SwiftUIRelux

extension Auth.UI.LocalAuth.Container.Page {
    struct Props: ViewProps {

    }

    struct Actions: ViewCallbacks, Equatable {
        let onTryLocalAuth: ViewCallback
    }
}
