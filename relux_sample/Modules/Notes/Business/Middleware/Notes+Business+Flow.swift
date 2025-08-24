// Relux Flow it's an entity which returns a specific Result
// to define has the flow completed successfully or failed
// during the all effects hierarchy

extension Notes.Business {
    protocol IFlow: Relux.Flow {}
}

extension Notes.Business {

    actor Flow {
        private typealias Model = Notes.Business.Model
        let dispatcher: Relux.Dispatcher
        private let svc: Notes.Business.IService

        init(
            dispatcher: Relux.Dispatcher? = .none,
            svc: Notes.Business.IService
        ) async {
            let defaultDispatcher =  await Self.defaultDispatcher
            self.dispatcher = dispatcher ?? defaultDispatcher
            self.svc = svc
        }
    }

}

extension Notes.Business.Flow: Notes.Business.IFlow {
    func apply(_ effect: any Relux.Effect) async -> Relux.Flow.Result {
        switch effect as? Notes.Business.Effect {
            case .none: .success
            case .obtainNotes: await obtainNotes()
            case let .upsert(note): await upsert(note)
            case let .delete(note): await delete(note)
        }
    }
}

extension Notes.Business.Flow {
    private func obtainNotes() async -> Relux.Flow.Result {
        // this flow returns it's result based on inner actions result
        switch await svc.getNotes() {
            case let .success(notes):
                // await for result
                await actions {
                    Notes.Business.Action.obtainNotesSuccess(notes: notes)
                }
                return .success
            case let .failure(err):
                // await for result
                await actions(.concurrently) {
                    Notes.Business.Action.obtainNotesFail(err: err)
                    ErrorHandling.Business.Effect.track(error: err)
                }
                return .success
        }
    }

    private func upsert(_ note: Model.Note) async -> Relux.Flow.Result {
        switch await svc.upsert(note: note) {
            case .success:
                await actions {
                    Notes.Business.Action.upsertNoteSuccess(note: note)
                }
                return .success
            case let .failure(err):
                await actions(.concurrently) {
                    Notes.Business.Action.upsertNoteFail(err: err)
                    ErrorHandling.Business.Effect.track(error: err)
                }
                // here we decided to fail flow with specific error
                return .failure(err)
        }
    }

    private func delete(_ note: Model.Note) async -> Relux.Flow.Result {
        switch await svc.delete(noteId: note.id) {
            case .success:
                await actions {
                    Notes.Business.Action.deleteNoteSuccess(note: note)
                }
                return .success
            case let .failure(err):
                await actions(.concurrently) {
                    Notes.Business.Action.deleteNoteFail(err: err)
                    ErrorHandling.Business.Effect.track(error: err)
                }
                // here we decided to fail flow with specific error
                return .failure(err)
        }
    }
}
