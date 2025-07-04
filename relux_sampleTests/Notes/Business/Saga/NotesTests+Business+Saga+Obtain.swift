import Testing
@testable import relux_sample

extension NotesTests.Business.Saga {
    struct Obtain {
        @Test func obtainNotes_Success() async throws {
                // Arrange
            let logger = Relux.Testing.Logger()
            let dispatcher = Relux.Dispatcher(logger: logger)

            let service = NotesTests.Business.ServiceMock()
            let flow = Notes.Business.Flow(dispatcher: dispatcher, svc: service)

            let notes: [Model.Note] = .stub
            service.obtainNotesHandler = { .success(notes) }

                // Act
            _ = await flow.apply(Effect.obtainNotes)

                // Assert
            let successAction = logger.getAction(Action.obtainNotesSuccess(notes: notes))
            #expect(successAction.isNotNil)
            #expect(service.obtainNotesCallCount == 1)
        }

        @Test func obtainNotes_Failure() async throws {
                // Arrange
            let logger = Relux.Testing.Logger()
            let dispatcher = Relux.Dispatcher(logger: logger)

            let service = NotesTests.Business.ServiceMock()
            let flow = Notes.Business.Flow(dispatcher: dispatcher, svc: service)

            let err: Err = .obtainFailed(cause: StubErr())
            service.obtainNotesHandler = { .failure(err) }

                // Act
            _ = await flow.apply(Effect.obtainNotes)

                // Assert
            let failureAction = logger.getAction(Action.obtainNotesFail(err: err))
            #expect(failureAction.isNotNil)

            let errEffect = logger.getEffect(ErrEffect.track(error: err))
            #expect(errEffect.isNotNil)
            #expect(service.obtainNotesCallCount == 1)
        }
    }
}
