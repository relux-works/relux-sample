import AuthReluxInt
import Relux
import SampleAppRoutes

struct AuthRouterAdapter: Auth.Business.IRouter {
    func setAuth(page: Auth.UI.Model.Page) -> any Relux.Action {
        AppRouter.Action.set([.auth(page)])
    }

    func pushMain() -> any Relux.Action {
        AppRouter.Action.push(.main)
    }
}
