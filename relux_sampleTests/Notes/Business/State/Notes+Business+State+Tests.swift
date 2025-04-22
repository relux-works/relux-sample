import Testing
@testable import relux_sample

extension NotesTests.Business.State {
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


