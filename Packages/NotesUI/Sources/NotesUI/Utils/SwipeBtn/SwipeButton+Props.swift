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
    
    struct Callbacks: Relux.UI.ViewCallbacks {
        let action: Relux.UI.ViewCallback<Void>
    }
}
