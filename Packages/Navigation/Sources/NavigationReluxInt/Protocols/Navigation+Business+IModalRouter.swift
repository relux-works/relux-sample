import Relux
import NavigationModels

extension Navigation.Business {
    /// Protocol for modal presentation state.
    public protocol IModalRouter: Relux.HybridState {
        var modalSheet: Navigation.Business.Model.ModalPage? { get }
    }
}
