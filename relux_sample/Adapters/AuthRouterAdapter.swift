import Auth
import Relux
import ReluxRouter

struct AuthRouterAdapter: Auth.Business.IRouter {
    func setAuth(page: Auth.UI.Model.Page) -> any Relux.Action {
        AppRouter.Action.set([.auth(page: page)])
    }

    func pushMain() -> any Relux.Action {
        AppRouter.Action.push(.app(page: .main))
    }
}
