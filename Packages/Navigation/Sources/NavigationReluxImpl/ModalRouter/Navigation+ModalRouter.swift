import Relux
import NavigationReluxInt

extension Navigation.Business {
    /// Simple single-sheet modal router.
    @Observable
    @MainActor
    public final class ModalRouter<ModalPage>: Navigation.Business.IModalRouter, @unchecked Sendable
    where ModalPage: Relux.Navigation.ModalComponent & Hashable & Sendable {

        public typealias Modal = ModalPage

        public var modalSheet: Modal?

        public init(initial: Modal? = nil) {
            self.modalSheet = initial
        }
    }
}

extension Navigation.Business.ModalRouter {
    public enum Action: Relux.Action {
        case present(page: Modal)
        case dismiss
    }

    public func reduce(with action: any Relux.Action) async {
        switch action as? Action {
        case .none: break
        case let .some(action): await internalReduce(with: action)
        }
    }

    public func cleanup() async {
        self.modalSheet = nil
    }

    func internalReduce(with action: Action) async {
        switch action {
        case let .present(page):
            guard self.modalSheet != page else { return }
            self.modalSheet = page
        case .dismiss:
            self.modalSheet = nil
        }
    }
}
