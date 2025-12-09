import Testing
import Relux
@testable import relux_sample

extension NotesTests.Business.State {
    struct UpsertNote {
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
}
//