import SwiftUI

public struct SwipeButton: View {
    private let props: Props
    private let actions: Actions

    public init(props: Props, actions: Actions) {
        self.props = props
        self.actions = actions
    }

    public var body: some View {
        content
    }

    private var content: some View {
        AsyncButton(action: actions.action) {
            props.icon
        }.tint(props.tint)
    }
}
