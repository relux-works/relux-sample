import Testing
@testable import relux_sample

extension NotesTests.Business.Saga {
    struct Upsert {
        fileprivate enum SuccessPhantom {}
        @Test func upsertNote_Success() async throws {
                // Arrange
            let reluxLogger = await Relux.Testing.MockModule<Action, Effect, SuccessPhantom>()
            await SampleApp.relux.register(reluxLogger)

            let service = NotesTests.Business.ServiceMock()
            let saga = Notes.Business.Saga(svc: service)

            let note = Model.Note.stubRandom()
            service.upsertNotesHandler = { _ in .success(()) }

                // Act
            await saga.apply(Effect.upsert(note: note))

                // Assert
            let successAction = await reluxLogger.getAction(Action.upsertNoteSuccess(note: note))
            #expect(successAction.isNotNil)
            #expect(service.upsertNotesCallCount == 1)

                // Teardown
            await SampleApp.relux.unregister(reluxLogger)
        }

        fileprivate enum FailurePhantom {}
        @Test func upsertNote_Failure() async throws {
                // Arrange
            let reluxLogger = await Relux.Testing.MockModule<Action, Effect, FailurePhantom>()
            await SampleApp.relux.register(reluxLogger)

            let service = NotesTests.Business.ServiceMock()
            let saga = Notes.Business.Saga(svc: service)

            let note = Model.Note.stubRandom()
            let err: Err = .upsertFailed(note: note, cause: StubErr())
            service.upsertNotesHandler = { _ in .failure(err) }

                // Act
            await saga.apply(Effect.upsert(note: note))

                // Assert
            let failureAction = await reluxLogger.getAction(Action.upsertNoteFail(err: err))
            #expect(failureAction.isNotNil)

            let errEffect = await reluxLogger.getEffect(ErrEffect.track(error: err))
            #expect(errEffect.isNotNil)
            #expect(service.upsertNotesCallCount == 1)

                // Teardown
            await SampleApp.relux.unregister(reluxLogger)
        }
    }
}
