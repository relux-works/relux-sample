import ReluxRouter

extension Navigation.Business.Model {
    enum ModalPage {
        case debug
    }
}

extension Navigation.Business.Model.ModalPage: Equatable {}
extension Navigation.Business.Model.ModalPage: Hashable {}
extension Navigation.Business.Model.ModalPage: Identifiable {
    var id: String {
        switch self {
            case .debug: "debug"
        }
    }
}
