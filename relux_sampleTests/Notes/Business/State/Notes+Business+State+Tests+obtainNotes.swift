import Testing
@testable import relux_sample

extension NotesTests.Business.State {
    @Test func obtainNotesSuccess() async throws {
        // Arrange
        let state = State()
        let notes: [Model.Note] = .stub
        let action = Action.obtainNotesSuccess(notes: notes)

        // Act
        await state.reduce(with: action)

        // Assert
        #expect(await state.notes == .success(notes))
    }

    @Test func obtainNotesFailure() async throws {
        // Arrange
        let state = State()
        let err: Err = .obtainFailed(cause: StubErr())
        let action = Action.obtainNotesFail(err: err)

        // Act
        await state.reduce(with: action)

        // Assert
        #expect(await state.notes == .failure(err))
    }
}
