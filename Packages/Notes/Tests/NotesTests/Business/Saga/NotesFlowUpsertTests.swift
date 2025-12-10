import Testing
import Relux
import NotesReluxImpl
import NotesReluxInt
import NotesTestSupport
import TestInfrastructure

@Suite
struct NotesFlowUpsertTests {
    @Test
    func upsert_success_dispatchesAction() async {
        let logger = Relux.Testing.Logger()
        let dispatcher = Relux.Dispatcher(logger: logger)
        let service = Notes.Business.ServiceMock()
        let flow = await Notes.Business.Flow(dispatcher: dispatcher, svc: service)

        let note: Notes.Business.Model.Note = .stub()
        service.stubUpsertSuccess()

        let result = await flow.apply(Notes.Business.Effect.upsert(note: note))

        if case .success = result {
            // ok
        } else {
            Issue.record("Expected success result")
        }
        #expect(service.upsertNotesCallCount == 1)
    }

    @Test
    func upsert_failure_dispatchesFail_and_tracksError() async {
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
        let err: Notes.Business.Err = .upsertFailed(note: note, cause: StubError())
        service.stubUpsertFailure(err)

        let result = await flow.apply(Notes.Business.Effect.upsert(note: note))

        if case .failure = result {
            #expect(true)
        } else {
            Issue.record("Expected failure result")
        }
        #expect(await tracker.count() == 1)
        #expect(service.upsertNotesCallCount == 1)
    }
}

private actor ErrorTracker {
    private(set) var callCount = 0
    func track(_ err: Notes.Business.Err) async {
        callCount += 1
    }

    func count() -> Int { callCount }
}
