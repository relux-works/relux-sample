import Testing
@testable import relux_sample

extension NotesTests.Business.Saga {
    struct Obtain {
        @Test func obtainNotes_Success() async throws {
                // Arrange
            let logger = Relux.Testing.Logger()
            let dispatcher = Relux.Dispatcher(logger: logger)

            let service = NotesTests.Business.ServiceMock()
            let flow = await Notes.Business.Flow(dispatcher: dispatcher, svc: service)

            let notes: [Model.Note] = .stub
            service.obtainNotesHandler = { .success(notes) }

                // Act
            let result: Relux.Flow.Result = await flow.apply(Effect.obtainNotes)
            guard case .success = result else {
                Issue.record("Expected success flow result")
                return
            }

                // Assert
            let successAction = logger.getAction(Action.snapshot(.init(revision: 1, notes: notes)))
            #expect(successAction.isNotNil)
            #expect(service.obtainNotesCallCount == 1)
        }


        @Test func obtainNotes_Failure() async throws {
                // Arrange
            let logger = Relux.Testing.Logger()
            let dispatcher = Relux.Dispatcher(logger: logger)

            let service = NotesTests.Business.ServiceMock()
            let flow = await Notes.Business.Flow(dispatcher: dispatcher, svc: service)

            let err: Err = .obtainFailed(cause: StubErr())
            service.obtainNotesHandler = { .failure(err) }

                // Act
            let result: Relux.Flow.Result = await flow.apply(Effect.obtainNotes)
            guard case .failure = result else {
                Issue.record("Expected failure flow result")
                return
            }

                // Assert
            let failureAction = logger.getAction(Action.obtainNotesFail(err: err))
            #expect(failureAction.isNotNil)

            let errEffect = logger.getEffect(ErrEffect.track(error: err))
            #expect(errEffect.isNotNil)
            #expect(service.obtainNotesCallCount == 1)
        }
    }
}
