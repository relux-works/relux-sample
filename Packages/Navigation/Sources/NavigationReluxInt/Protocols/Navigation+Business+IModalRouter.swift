import Relux

extension Navigation.Business {
    /// Protocol for modal presentation state.
    public protocol IModalRouter: Relux.Navigation.RouterProtocol {
        associatedtype Modal: Relux.Navigation.ModalComponent & Hashable & Sendable
        var modalSheet: Modal? { get }
    }
}
