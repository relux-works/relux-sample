import AuthModels
import Relux

extension Auth.Business {
    public protocol IState: Relux.HybridState {}
}


extension Auth.Business {
    public protocol ISaga: Relux.Saga {}
}


extension Auth.Business {    
    public protocol IRouter: Sendable {
        func setAuth(page: Auth.UI.Model.Page) -> any Relux.Action
        func pushMain() -> any Relux.Action
    }
}
