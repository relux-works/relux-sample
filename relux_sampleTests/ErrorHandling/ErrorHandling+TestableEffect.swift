import Relux
@testable import relux_sample

extension ErrorHandling.Business.Effect {
    enum TestableEffect: Equatable {
        case track(err: String)
    }
}

extension ErrorHandling.Business.Effect {
    var asTestableEffect: TestableEffect {
        switch self {
            case let .track(err): .track(err: err.localizedDescription)
        }
    }
}

extension Relux.Testing.MockModule {
    func getEffect(_ effect: ErrorHandling.Business.Effect) async -> ErrorHandling.Business.Effect? {
        await self
            .effectsLogger
            .effects
            .compactMap { $0 as? ErrorHandling.Business.Effect }
            .first { $0.asTestableEffect == effect.asTestableEffect }
    }
}
