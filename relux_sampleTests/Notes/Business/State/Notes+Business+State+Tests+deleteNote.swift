import Testing
@testable import relux_sample

extension NotesTests.Business.State {
    @Test func deleteNoteSuccess() async throws {
        // Arrange
        let state = State()
        let initialNotes: [Model.Note] = .stub
        let noteToRemove = initialNotes.first!

        let obtainAction = Action.obtainNotesSuccess(notes: initialNotes)
        await state.reduce(with: obtainAction)

        let deleteAction = Action.deleteNoteSuccess(note: noteToRemove)
        
        // Act
        await state.reduce(with: deleteAction)

        // Assert
        guard let notes = await state.notes.value else {
            Issue.record("notes MaybeData should be success")
            return
        }
        #expect(notes.count == initialNotes.count - 1)
        #expect(notes.contains(noteToRemove).not)
    }
}
