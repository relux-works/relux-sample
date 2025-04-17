import Foundation

extension SwipeButton {
    public struct Props {
        let icon: Image
        let tint: Color

        public init(
            icon: Image,
            tint: Color
        ) {
            self.icon = icon
            self.tint = tint
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
