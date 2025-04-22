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

extension Relux.Testing.MockModule {
    func getEffect(_ effect: Notes.Business.Effect) async -> Notes.Business.Effect? {
        await self
            .effectsLogger
            .effects
            .compactMap { $0 as? Notes.Business.Effect }
            .first { $0.asTestableEffect == effect.asTestableEffect }
    }
}
