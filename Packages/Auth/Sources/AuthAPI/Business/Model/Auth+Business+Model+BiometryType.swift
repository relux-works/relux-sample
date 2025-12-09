import Foundation

extension Auth.Business.Model {
    public enum BiometryType: Equatable, Sendable {
        case touch(allowed: Bool)
        case face(allowed: Bool)
        case other(allowed: Bool)
    }
}

extension Auth.Business.Model.BiometryType {
    public var allowed: Bool {
        switch self {
            case let .face(allowed): allowed
            case let .touch(allowed): allowed
            case let .other(allowed): allowed
        }
    }
}
