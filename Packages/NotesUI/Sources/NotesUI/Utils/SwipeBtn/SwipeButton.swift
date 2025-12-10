import SwiftUI
import Relux

struct SwipeButton: Relux.UI.View {
    
    let props: Props
    private let actions: Callbacks

    init(props: Props, actions: Callbacks) {
        self.props = props
        self.actions = actions
    }

    var body: some View {
        AsyncButton(action: actions.action) {
            props.icon
        }
        .tint(props.tint)
    }
}
