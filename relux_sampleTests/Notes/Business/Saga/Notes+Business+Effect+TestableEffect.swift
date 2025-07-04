import Relux
@testable import relux_sample

extension Notes.Business.Effect {
    enum TestableEffect: Equatable {
        typealias Model = Notes.Business.Model

        // without uuid equating will always succeed, even if it different effects
        case notImplemented(_ uuid: UUID = .init())
    }
}

extension Notes.Business.Effect {
    var asTestableEffect: TestableEffect {
        .notImplemented()
    }
}
