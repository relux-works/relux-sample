import Relux

extension Navigation.Business {
    /// Protocol for the main navigation router state.
    /// Implemented by `Relux.Navigation.ProjectingRouter` in NavigationReluxImpl.
    public protocol IRouter: Relux.Navigation.RouterProtocol {}
}
