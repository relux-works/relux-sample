import SwiftUI
import Relux

extension SwipeButton {
    struct Props: Relux.UI.ViewProps {
        let icon: Image
        let tint: Color

        init(icon: Image, tint: Color) {
            self.icon = icon
            self.tint = tint
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(tint)
        }
    }

    struct Actions {
        let action: @Sendable () async -> Void

        init(action: @escaping @Sendable () async -> Void) {
            self.action = action
        }
    }
}
