import Relux
import NavigationModels

extension Navigation.Business {
    /// Protocol for modal presentation state.
    public protocol IModalRouter: Relux.Navigation.RouterProtocol {
        var modalSheet: Navigation.Business.Model.ModalPage? { get }
    }
}
