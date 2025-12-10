import Testing
import Relux
import NotesReluxImpl
import NotesReluxInt
import NotesTestSupport
import TestInfrastructure

@Suite
struct NotesFlowObtainTests {
    @Test
    func obtainNotes_success_dispatchesAction() async {
        let logger = Relux.Testing.Logger()
        let dispatcher = Relux.Dispatcher(logger: logger)
        let service = Notes.Business.ServiceMock()
        let flow = await Notes.Business.Flow(dispatcher: dispatcher, svc: service)

        let notes: [Notes.Business.Model.Note] = .stub(count: 3)
        service.stubObtainSuccess(notes)

        _ = await flow.apply(Notes.Business.Effect.obtainNotes)

        #expect(service.obtainNotesCallCount == 1)
    }

    @Test
    func obtainNotes_failure_dispatchesFail_and_tracksError() async {
        let logger = Relux.Testing.Logger()
        let dispatcher = Relux.Dispatcher(logger: logger)
        let service = Notes.Business.ServiceMock()
        let tracker = ErrorTracker()

        let flow = await Notes.Business.Flow(
            dispatcher: dispatcher,
            svc: service,
            onError: tracker.track
        )

        let err: Notes.Business.Err = .obtainFailed(cause: StubError())
        service.stubObtainFailure(err)

        _ = await flow.apply(Notes.Business.Effect.obtainNotes)

        #expect(await tracker.count() == 1)
        #expect(service.obtainNotesCallCount == 1)
    }
}

private actor ErrorTracker {
    private(set) var callCount = 0

    func track(_ err: Notes.Business.Err) async {
        callCount += 1
    }

    func count() -> Int { callCount }
}
