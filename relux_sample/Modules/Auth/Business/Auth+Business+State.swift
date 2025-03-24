import Foundation

extension Auth.Business {
    // ALARM! it's important to mark any UIState or HybridState as @MainActor isolation
    // Relux doesn't conform @MainActor global actor isolation to state protocols consciously
    // it's related to specific non-obvious behaviour for this conformance
    @Observable
    @MainActor
    final class State {
        typealias Model = Auth.Business.Model

        var availableBiometryType: Model.BiometryType?
        var loggedIn: Bool = false
    }
}

extension Auth.Business.State: Relux.HybridState {
    func reduce(with action: any Relux.Action) async {
        switch action as? Auth.Business.Action {
            case .none: break
            case let .some(action): internalReduce(with: action)
        }
    }

    func cleanup() async {
        self.loggedIn = false
        self.availableBiometryType = .none
    }
}
