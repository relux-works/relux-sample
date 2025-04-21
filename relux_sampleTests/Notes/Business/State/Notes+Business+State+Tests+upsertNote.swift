import Testing
@testable import relux_sample

extension Notes_Business_State_Tests {
    @Test func upsertNoteSuccess() async throws {
        // Arrange
        let state = State()
        let note: Model.Note = .stubRandom()
        let action = Action.upsertNoteSuccess(note: note)

        // Act
        await state.reduce(with: action)

        // Assert
        #expect(await state.notes == .success([note]))
    }
}
