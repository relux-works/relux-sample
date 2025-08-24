import Testing
@testable import relux_sample

extension NotesTests.Business.Saga {
    struct Delete {

        @Test func deleteNote_Success() async throws {
                // Arrange
            let logger = Relux.Testing.Logger()
            let dispatcher = Relux.Dispatcher(logger: logger)

            let service = NotesTests.Business.ServiceMock()
            let flow =  Notes.Business.Flow(dispatcher: dispatcher, svc: service)

            let note = Model.Note.stubRandom()
            service.deleteNotesHandler = { _ in .success(()) }

                // Act
            _ = await flow.apply(Effect.delete(note: note))

                // Assert
            let successAction = logger.getAction(Action.deleteNoteSuccess(note: note))
            #expect(successAction.isNotNil)
            #expect(service.deleteNotesCallCount == 1)
        }

        @Test func deleteNote_Failure() async throws {
            // Arrange
            let logger = Relux.Testing.Logger()
            let dispatcher = Relux.Dispatcher(logger: logger)

            let service = NotesTests.Business.ServiceMock()
            let flow =  Notes.Business.Flow(dispatcher: dispatcher, svc: service)

            let note = Model.Note.stubRandom()
            let err: Err = .deleteFailed(noteId: note.id, cause: StubErr())
            service.deleteNotesHandler = { _ in .failure(err) }

            // Act
            _ = await flow.apply(Effect.delete(note: note))

            // Assert
            #expect(service.deleteNotesCallCount == 1)

            let failureAction = logger.getAction(Action.deleteNoteFail(err: err))
            #expect(failureAction.isNotNil)

            let errEffect = logger.getEffect(ErrEffect.track(error: err))
            #expect(errEffect.isNotNil)
        }
    }
}
