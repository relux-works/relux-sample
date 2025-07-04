import Testing
import Relux
@testable import relux_sample

extension NotesTests.Business.Saga {
    typealias Action = Notes.Business.Action
    typealias Effect = Notes.Business.Effect
    typealias Err = Notes.Business.Err
    typealias Model = Notes.Business.Model

    typealias AppRouterAction = AppRouter.Action
    typealias AuthEffect = Auth.Business.Effect
    typealias ErrEffect = ErrorHandling.Business.Effect
}

extension Relux.Testing.Logger {
    func getAction(_ action: Notes.Business.Action) -> Notes.Business.Action? {
        self
            .actions
            .compactMap { $0 as? Notes.Business.Action }
            .first { $0.asTestableAction == action.asTestableAction }
    }

    func getEffect(_ effect: ErrorHandling.Business.Effect) -> ErrorHandling.Business.Effect? {
        self
            .effects
            .compactMap { $0 as? ErrorHandling.Business.Effect }
            .first { $0.asTestableEffect == effect.asTestableEffect }
    }
}
