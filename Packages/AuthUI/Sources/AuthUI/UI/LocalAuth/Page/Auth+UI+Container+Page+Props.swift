import Auth
import SwiftUIRelux

extension Auth.UI.LocalAuth.Container.Page {
    struct Props: ViewProps {

    }

    struct Actions: ViewCallbacks {
        let onTryLocalAuth: ViewCallback<Void>
    }
}
