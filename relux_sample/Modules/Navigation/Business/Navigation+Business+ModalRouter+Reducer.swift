extension Navigation.Business.ModalRouter {
    func internalReduce(with action: Action) async {
        switch action {
            case let .present(page):
                guard self.modalSheet != page else { return }
                self.modalSheet = page
            case .dismiss:
                self.modalSheet = .none
        }
    }
}
