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
