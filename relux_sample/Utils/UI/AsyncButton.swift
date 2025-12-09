import SwiftUI

public struct TabViewItemButtonStyle: ButtonStyle {
    public init() {}

    @MainActor
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}

@MainActor
public struct AsyncButton<Label: View>: View {
    public typealias Action = @Sendable () async -> Void

    private let actionPriority: TaskPriority?
    private let actionOptions: Set<ActionOption>
    private let role: ButtonRole?
    private let action: Action

    @State private var isDisabled = false
    @State private var showProgress = false
    private let label: Label

    public init(
        actionPriority: TaskPriority? = nil,
        actionOptions: Set<ActionOption> = [ActionOption.disableButton],
        role: ButtonRole? = .none,
        action: @escaping Action,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.actionPriority = actionPriority
        self.actionOptions = actionOptions
        self.role = role
        self.action = action
        self.label = label()
    }

    public var body: some View {
        Button(role: role, action: customizedAction) {
            label
                .opacity(showProgress ? 0 : 1)
                .overlay(progressView)
        }
        .disabled(isDisabled)
    }

    @ViewBuilder
    private var progressView: some View {
        if showProgress { ProgressView() } else { EmptyView() }
    }

    private func customizedAction() {
        if actionOptions.contains(.disableButton) {
            isDisabled = true
        }

        Task(priority: actionPriority) { @MainActor in
            var progressViewTask: Task<Void, Never>?

            if actionOptions.contains(.showProgressView) {
                progressViewTask = Task { @MainActor in
                    try? await Task.sleep(nanoseconds: 150_000_000)
                    showProgress = true
                }
            }

            await action()
            progressViewTask?.cancel()

            isDisabled = false
            showProgress = false
        }
    }
}

public extension AsyncButton {
    init(
        actionPriority: TaskPriority? = nil,
        actionOptions: Set<ActionOption> = [ActionOption.disableButton],
        role: ButtonRole? = .none,
        action: Relux.UI.ViewCallback,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.actionPriority = actionPriority
        self.actionOptions = actionOptions
        self.role = role
        self.action = { await action() }
        self.label = label()
    }
}

public extension AsyncButton where Label == Text {
    init(
        _ label: String,
        actionOptions: Set<ActionOption> = Set(ActionOption.allCases),
        action: @escaping Action
    ) {
        self.init(actionOptions: actionOptions, action: action) {
            Text(label)
        }
    }
}

public extension AsyncButton where Label == Image {
    init(
        systemImageName: String,
        actionOptions: Set<ActionOption> = Set(ActionOption.allCases),
        action: @escaping Action
    ) {
        self.init(actionOptions: actionOptions, action: action) {
            Image(systemName: systemImageName)
        }
    }
}

public extension AsyncButton {
    enum ActionOption: CaseIterable {
        case disableButton
        case showProgressView
    }
}
