import Testing
@testable import relux_sample

@Suite(.timeLimit(.minutes(1)))
struct Notes_Business_State_Tests {
    typealias Model = Notes.Business.Model
    typealias Action = Notes.Business.Action
    typealias State = Notes.Business.State
    typealias Err = Notes.Business.Err

    @Test func initialState() async throws {
        // Arrange
        let state = State()

        // Assert
        guard case .initial = await state.notes else {
            Issue.record("notes should be initial")
            return
        }
    }
}


