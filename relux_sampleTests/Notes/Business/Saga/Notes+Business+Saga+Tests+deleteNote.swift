import Testing
@testable import relux_sample

extension NotesTests.Business.Saga {
    fileprivate enum SuccessPhantom {}
    @Test func deleteNote_Success() async throws {
        // Arrange
        let reluxLogger = await Relux.Testing.MockModule<Action, Effect, SuccessPhantom>()
        _ = await Task { @MainActor in await SampleApp.relux.register(reluxLogger) }.value

        let service = Notes.Business.ServiceMock()
        let saga = Notes.Business.Saga(svc: service)

        let note = Model.Note.stubRandom()
        service.deleteNotesHandler = { _ in .success(()) }

        // Act
        await saga.apply(Effect.delete(note: note))

        // Assert
        let successAction = await reluxLogger.getAction(Action.deleteNoteSuccess(note: note))
        #expect(successAction.isNotNil)
    }

    fileprivate enum FailurePhantom {}
    @Test func deleteNote_Failure() async throws {
        // Arrange
        let reluxLogger = await Relux.Testing.MockModule<Action, Effect, FailurePhantom>()
        _ = await Task { @MainActor in await SampleApp.relux.register(reluxLogger) }.value

        let service = Notes.Business.ServiceMock()
        let saga = Notes.Business.Saga(svc: service)

        let note = Model.Note.stubRandom()
        let err: Err = .deleteFailed(noteId: note.id, cause: StubErr())
        service.deleteNotesHandler = { _ in .failure(err) }

        // Act
        await saga.apply(Effect.delete(note: note))

        // Assert
        let failureAction = await reluxLogger.getAction(Action.deleteNoteFail(err: err))
        #expect(failureAction.isNotNil)

        let errEffect = await reluxLogger.getEffect(ErrEffect.track(error: err))
        #expect(errEffect.isNotNil)
    }
}
