import Testing
import Relux
@testable import relux_sample

@Suite(.serialized, .timeLimit(.minutes(1)))
struct Notes_Business_Saga_Tests {
    typealias Action = Notes.Business.Action
    typealias Effect = Notes.Business.Effect
    typealias Err = Notes.Business.Err
    typealias Model = Notes.Business.Model

    typealias AppRouterAction = AppRouter.Action
    typealias AuthEffect = Auth.Business.Effect
    typealias ErrEffect = ErrorHandling.Business.Effect
}
