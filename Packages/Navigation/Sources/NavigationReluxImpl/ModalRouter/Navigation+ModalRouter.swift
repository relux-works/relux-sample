import Relux
import NavigationReluxInt

extension Navigation.Business {
    @Observable
    @MainActor
    public final class ModalRouter: Navigation.Business.IModalRouter, @unchecked Sendable {
        public var modalSheet: Navigation.Business.Model.ModalPage?

        public init() {}
    }
}

extension Navigation.Business.ModalRouter {
    public func reduce(with action: any Relux.Action) async {
        switch action as? Action {
        case .none: break
        case let .some(action): await internalReduce(with: action)
        }
    }

    public func cleanup() async {
        self.modalSheet = nil
    }
}
