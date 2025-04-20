extension Navigation.Business.ModalRouter {

    enum Action: Relux.Action {
        typealias Model = Navigation.Business.Model

        case present(page: Model.ModalPage)
        case dismiss
    }
}
