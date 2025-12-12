import Relux
import ReluxRouter
import NavigationReluxInt

extension Navigation.Business {
    /// Main navigation router using Destination directly as page type.
    public typealias Router = Relux.Navigation.ProjectingRouter<Navigation.UI.Model.Destination>
}

extension Navigation.Business.Router: Navigation.Business.IRouter {}

/// Convenience type alias for host app bindings.
public typealias AppRouter = Navigation.Business.Router
