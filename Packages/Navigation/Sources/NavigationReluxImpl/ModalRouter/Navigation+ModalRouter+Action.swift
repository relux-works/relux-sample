import Relux
import NavigationReluxInt

extension Navigation.Business.ModalRouter {
    public enum Action: Relux.Action {
        case present(page: Navigation.Business.Model.ModalPage)
        case dismiss
    }
}
