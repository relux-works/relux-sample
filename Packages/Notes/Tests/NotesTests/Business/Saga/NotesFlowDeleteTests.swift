import Testing
import Relux
import NotesReluxImpl
import NotesReluxInt
import NotesTestSupport
import TestInfrastructure

@Suite
struct NotesFlowDeleteTests {
    @Test
    func delete_success_dispatchesAction() async {
        let logger = Relux.Testing.Logger()
        let dispatcher = Relux.Dispatcher(logger: logger)
        let service = Notes.Business.ServiceMock()
        let flow = await Notes.Business.Flow(dispatcher: dispatcher, svc: service)

        let note: Notes.Business.Model.Note = .stub()
        service.stubDeleteSuccess()

        let result = await flow.apply(Notes.Business.Effect.delete(note: note))

        if case .success = result {
            // ok
        } else {
            Issue.record("Expected success result")
        }
        #expect(service.deleteNotesCallCount == 1)
    }

    @Test
    func delete_failure_dispatchesFail_and_tracksError() async {
        let logger = Relux.Testing.Logger()
        let dispatcher = Relux.Dispatcher(logger: logger)
        let service = Notes.Business.ServiceMock()
        let tracker = ErrorTracker()

        let flow = await Notes.Business.Flow(
            dispatcher: dispatcher,
            svc: service,
            onError: tracker.track
        )

        let note: Notes.Business.Model.Note = .stub()
        let err: Notes.Business.Err = .deleteFailed(noteId: note.id, cause: StubError())
        service.stubDeleteFailure(err)

        let result = await flow.apply(Notes.Business.Effect.delete(note: note))

        if case .failure = result {
            #expect(true)
        } else {
            Issue.record("Expected failure result")
        }
        #expect(await tracker.count() == 1)
        #expect(service.deleteNotesCallCount == 1)
    }
}

private actor ErrorTracker {
    private(set) var callCount = 0
    func track(_ err: Notes.Business.Err) async {
        callCount += 1
    }

    func count() -> Int { callCount }
}
