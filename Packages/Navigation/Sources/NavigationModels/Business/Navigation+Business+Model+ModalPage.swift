import Relux

extension Navigation.Business.Model {
    public enum ModalPage: Sendable, Hashable, Identifiable {
        case debug

        public var id: String {
            switch self {
            case .debug: "modal-debug"
            }
        }
    }
}
