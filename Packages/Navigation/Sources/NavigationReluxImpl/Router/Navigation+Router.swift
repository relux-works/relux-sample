import Relux
import ReluxRouter
import NavigationReluxInt

/// Any projecting router can be used as Navigation's main router.
extension Relux.Navigation.ProjectingRouter: Navigation.Business.IRouter where Page: Relux.Navigation.PathComponent {}
