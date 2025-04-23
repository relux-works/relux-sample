import Testing
@testable import relux_sample

extension NotesTests.Business.State {
    @Suite
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

    @Suite
    struct DeleteNote {
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

    @Suite
    struct ObtainNotes {
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

    @Suite
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
