import SwiftUI

protocol BindableState: AnyObject, Observable {
    var binding: Bindable<T> { get }
}

extension BindableState {
    typealias T = Self
    var binding: Bindable<Self> { Bindable(self) }
}
