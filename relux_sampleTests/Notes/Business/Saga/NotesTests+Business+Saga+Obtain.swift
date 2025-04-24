import Testing
@testable import relux_sample

extension NotesTests.Business.Saga {
    struct Obtain {
        private enum SuccessPhantom {}
        @Test func obtainNotes_Success() async throws {
                // Arrange
            let reluxLogger = await Relux.Testing.MockModule<Action, Effect, SuccessPhantom>()
            await SampleApp.relux.register(reluxLogger)

            let service = NotesTests.Business.ServiceMock()
            let saga = Notes.Business.Saga(svc: service)

            let notes: [Model.Note] = .stub
            service.obtainNotesHandler = { .success(notes) }

                // Act
            await saga.apply(Effect.obtainNotes)

                // Assert
            let successAction = await reluxLogger.getAction(Action.obtainNotesSuccess(notes: notes))
            #expect(successAction.isNotNil)
            #expect(service.obtainNotesCallCount == 1)

                // Teardown
            await SampleApp.relux.unregister(reluxLogger)
        }

        private enum FailurePhantom {}
        @Test func obtainNotes_Failure() async throws {
                // Arrange
            let reluxLogger = await Relux.Testing.MockModule<Action, Effect, FailurePhantom>()
            await SampleApp.relux.register(reluxLogger)

            let service = NotesTests.Business.ServiceMock()
            let saga = Notes.Business.Saga(svc: service)

            let err: Err = .obtainFailed(cause: StubErr())
            service.obtainNotesHandler = { .failure(err) }

                // Act
            await saga.apply(Effect.obtainNotes)

                // Assert
            let failureAction = await reluxLogger.getAction(Action.obtainNotesFail(err: err))
            #expect(failureAction.isNotNil)

            let errEffect = await reluxLogger.getEffect(ErrEffect.track(error: err))
            #expect(errEffect.isNotNil)
            #expect(service.obtainNotesCallCount == 1)

                // Teardown
            await SampleApp.relux.unregister(reluxLogger)
        }
    }
}
