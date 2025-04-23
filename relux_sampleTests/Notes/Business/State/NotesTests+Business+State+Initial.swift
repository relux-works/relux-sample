import Testing
@testable import relux_sample

extension NotesTests.Business.State {
    struct InitialValue {
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
}
