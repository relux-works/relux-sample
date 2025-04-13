import Foundation

extension Auth.Business {
    protocol IState: Relux.HybridState {}
}

extension Auth.Business {
    // IMPORTANT! conform your UIState or HybridState to corresponding Relux State protocol in class declaration
    // Relux applies @MainActor global actor isolation to UIState and HybridState state protocol definitions
    // it's related to specific non-obvious behaviour for this conformance
    @Observable
    final class State: Auth.Business.IState {
        typealias Model = Auth.Business.Model

        var availableBiometryType: Model.BiometryType?

        func reduce(with action: any Relux.Action) async {
            switch action as? Auth.Business.Action {
                case .none: break
                case let .some(action): internalReduce(with: action)
            }
        }

        func cleanup() async {
            self.availableBiometryType = .none
        }
    }
}
