import SwiftUI

/// Protocol for @Observable states that need SwiftUI Bindings.
public protocol BindableState: AnyObject, Observable {
    var binding: Bindable<T> { get }
}

extension BindableState {
    public typealias T = Self
    public var binding: Bindable<Self> { Bindable(self) }
}

extension Navigation.Business.ModalRouter: BindableState {}
