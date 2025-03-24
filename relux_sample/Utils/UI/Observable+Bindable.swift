import SwiftUI

protocol AnyBindable: AnyObject, Observable {
    var binding: Bindable<T> { get }
}

extension AnyBindable {
    typealias T = Self
    var binding: Bindable<Self> { Bindable(self) }
}
