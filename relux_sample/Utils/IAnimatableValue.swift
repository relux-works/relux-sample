//
//  IAnimatableValue.swift
//  relux_sample
//
//


public protocol IAnimatableValue {
    var asAnimatableValue: Int { get }
}

extension Result: IAnimatableValue {}
public extension Result {
    var asAnimatableValue: Int {
        switch self {
            case .success: return 1
            case .failure: return -1
        }
    }
}

public extension Optional where Wrapped: IAnimatableValue {
    var asAnimatableValue: Int {
        switch self {
            case .none: return 0
            case let .some(value): return value.asAnimatableValue
        }
    }
}
