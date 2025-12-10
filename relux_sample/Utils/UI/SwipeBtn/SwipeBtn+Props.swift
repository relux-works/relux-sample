import Foundation
import SwiftUI

extension SwipeButton {
    public struct Props: Relux.UI.ViewProps {
        let icon: Image
        let tint: Color

        public init(
            icon: Image,
            tint: Color
        ) {
            self.icon = icon
            self.tint = tint
        }
        
        public func hash(into hasher: inout Hasher) {
            hasher.combine(tint)
        }
    }

    public struct Actions {
        let action: @Sendable () async -> ()

        public init(
            action : @escaping @Sendable () async -> ()
        ) {
            self.action = action
        }
    }
}
