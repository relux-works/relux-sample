import SwiftUI

/// Button that prevents multiple taps while action is in progress.
public struct AsyncButton<Label: View>: View {
    private let action: @Sendable () async -> Void
    private let label: Label

    @State private var isRunning = false

    public init(
        action: @escaping @Sendable () async -> Void,
        @ViewBuilder label: () -> Label
    ) {
        self.action = action
        self.label = label()
    }

    public var body: some View {
        Button {
            guard !isRunning else { return }
            isRunning = true
            Task {
                await action()
                isRunning = false
            }
        } label: {
            label
        }
        .disabled(isRunning)
    }
}

extension AsyncButton where Label == Text {
    /// Creates an async button with a text label.
    public init(
        _ title: String,
        action: @escaping @Sendable () async -> Void
    ) {
        self.action = action
        self.label = Text(title)
    }
}
