import Relux

extension Auth.UI.Model {
    public enum Page: Relux.Navigation.PathComponent {
        case logoutFlow
        case localAuth
    }
}
