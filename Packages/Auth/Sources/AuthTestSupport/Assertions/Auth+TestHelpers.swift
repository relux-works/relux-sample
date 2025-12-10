import AuthModels
import AuthReluxInt
import Relux

extension Auth.Business.Action {
    /// Equatable wrapper for test assertions
    public enum TestableAction: Equatable {
        case authSucceed
        case authFailed(errDescription: String)
        case obtainBiometrySucceed(type: Auth.Business.Model.BiometryType)
        case logOutSucceed
    }

    public var asTestable: TestableAction {
        switch self {
            case .authSucceed: .authSucceed
            case .authFailed(let err): .authFailed(errDescription: err.localizedDescription)
            case .obtainAvailableBiometryTypeSucceed(let type): .obtainBiometrySucceed(type: type)
            case .logOutSucceed: .logOutSucceed
        }
    }
}

extension Relux.Testing.Logger {
    public func getAuthAction(_ action: Auth.Business.Action) -> Auth.Business.Action? {
        actions
            .compactMap { $0 as? Auth.Business.Action }
            .first { $0.asTestable == action.asTestable }
    }
}
