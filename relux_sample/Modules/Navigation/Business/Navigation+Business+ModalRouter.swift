extension Navigation.Business {
    @Observable
    final class ModalRouter: Relux.HybridState, BindableState {
        var modalSheet: Model.ModalPage?
    }
}

extension Navigation.Business.ModalRouter {
    func reduce(with action: any Relux.Action) async {
        switch action as? Action {
            case .none: break
            case let .some(action): await internalReduce(with: action)
        }
    }

    func cleanup() async {
        self.modalSheet = nil
    }
}
