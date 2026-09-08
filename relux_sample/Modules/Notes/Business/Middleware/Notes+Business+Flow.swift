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
            // Resolve the global dispatcher only when no explicit dependency was supplied.
            if let dispatcher {
                self.dispatcher = dispatcher
            } else {
                self.dispatcher = await Self.defaultDispatcher
            }
            self.svc = svc
        }
    }

}

extension Notes.Business.Flow: Notes.Business.IFlow {
    func apply(_ effect: any Relux.Effect) async -> Relux.Flow.Result {
        switch effect as? Notes.Business.Effect {
            case .none: .success
            case let .setProtection(id, protected): await updateProtection(id, protected: protected)
            case let .unlock(id): await unlock(id)
            case let .relock(id): await relock(id)
            case .obtainNotes: await obtainNotes()
            case let .upsert(note): await upsert(note)
            case let .delete(note): await delete(note)
        }
    }
}

extension Notes.Business.Flow {
    private func obtainNotes() async -> Relux.Flow.Result {
        // this flow returns it's result based on inner actions result
        switch await svc.getSnapshot() {
            case let .success(snapshot):
                // await for result
                await actions {
                    Notes.Business.Action.snapshot(snapshot)
                }
                return .success
            case let .failure(err):
                // await for result
                await actions(.concurrently) {
                    Notes.Business.Action.obtainNotesFail(err: err)
                    ErrorHandling.Business.Effect.track(error: err)
                }
                // Logging the error does not turn the failed operation into a successful flow.
                return .failure(err)
        }
    }

    private func upsert(_ note: Model.Note) async -> Relux.Flow.Result {
        switch await svc.upsert(note: note) {
            case .success:
                return await obtainNotes()
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
                return await obtainNotes()
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

extension Notes.Business.Flow {
    private func updateProtection(_ id: Model.Note.Id, protected: Bool) async -> Relux.Flow.Result {
        let result = await svc.setProtection(noteId: id, protected: protected)
        return await publishProtection(result)
    }
    private func unlock(_ id: Model.Note.Id) async -> Relux.Flow.Result {
        let result = await svc.unlock(noteId: id)
        return await publishProtection(result)
    }
    private func relock(_ id: Model.Note.Id?) async -> Relux.Flow.Result {
        await svc.relock(noteId: id)
        return await obtainNotes()
    }
    private func publishProtection(_ result: Swift.Result<Void, Notes.Business.Err>) async -> Relux.Flow.Result {
        let refresh = await obtainNotes()
        switch result {
        case .success: return refresh
        case .failure(let error): return .failure(error)
        }
    }
}
