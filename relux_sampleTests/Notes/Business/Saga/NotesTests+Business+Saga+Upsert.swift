import Testing
@testable import relux_sample

extension NotesTests.Business.Saga {
    struct Upsert {
        @Test func upsertNote_Success() async throws {
                // Arrange
            let logger = Relux.Testing.Logger()
            let dispatcher = Relux.Dispatcher(logger: logger)

            let service = NotesTests.Business.ServiceMock()
            let flow = Notes.Business.Flow(dispatcher: dispatcher, svc: service)

            let note = Model.Note.stubRandom()
            service.upsertNotesHandler = { _ in .success(()) }

                // Act
            _ = await flow.apply(Effect.upsert(note: note))

                // Assert
            let successAction = logger.getAction(Action.upsertNoteSuccess(note: note))
            #expect(successAction.isNotNil)
            #expect(service.upsertNotesCallCount == 1)
        }

        @Test func upsertNote_Failure() async throws {
                // Arrange
            let logger = Relux.Testing.Logger()
            let dispatcher = Relux.Dispatcher(logger: logger)
            let service = NotesTests.Business.ServiceMock()
            let flow = Notes.Business.Flow(dispatcher: dispatcher, svc: service)

            let note = Model.Note.stubRandom()
            let err: Err = .upsertFailed(note: note, cause: StubErr())
            service.upsertNotesHandler = { _ in .failure(err) }

                // Act
            _ = await flow.apply(Effect.upsert(note: note))

                // Assert
            let failureAction = logger.getAction(Action.upsertNoteFail(err: err))
            #expect(failureAction.isNotNil)

            let errEffect = logger.getEffect(ErrEffect.track(error: err))
            #expect(errEffect.isNotNil)
            #expect(service.upsertNotesCallCount == 1)
        }
    }
}
