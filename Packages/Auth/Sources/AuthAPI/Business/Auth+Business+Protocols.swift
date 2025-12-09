import LocalAuthentication
import Relux

extension Auth.Business {
    public protocol IState: Relux.HybridState {}
    public protocol IService: Sendable {
        typealias Err = Auth.Business.Err
        typealias Model = Auth.Business.Model

        var laContext: LAContext { get async }
        var availableBiometry: Model.BiometryType { get async }
        func runLocalAuth() async -> Result<Bool, Err>
        func recreateLAContext() async
    }

    public protocol ISaga: Relux.Saga {}

    public protocol IRouter: Sendable {
        func setAuth(page: Auth.UI.Model.Page) -> any Relux.Action
        func pushMain() -> any Relux.Action
    }
}
