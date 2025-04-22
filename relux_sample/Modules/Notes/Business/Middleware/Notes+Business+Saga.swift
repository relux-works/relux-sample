extension Notes.Business {
    protocol ISaga: Relux.Saga {}
}

extension Notes.Business {
    actor Saga {
        private typealias Model = Notes.Business.Model
        private let svc: Notes.Business.IService

        init(
            svc: Notes.Business.IService
        ) {
            self.svc = svc
        }
    }
}

extension Notes.Business.Saga: Notes.Business.ISaga {
    func apply(_ effect: any Relux.Effect) async {
        switch effect as? Notes.Business.Effect {
            case .none: break
            case .obtainNotes: await obtainNotes()
            case let .upsert(note): await upsert(note)
            case let .delete(note): await delete(note)
        }
    }
}

extension Notes.Business.Saga {
    private func obtainNotes() async {
        switch await svc.getNotes() {
            case let .success(notes):
                await action { Notes.Business.Action.obtainNotesSuccess(notes: notes) }
            case let .failure(err):
                await actions(.concurrently) {
                    Notes.Business.Action.obtainNotesFail(err: err)
                    ErrorHandling.Business.Effect.track(error: err)
                }
        }
    }

    private func upsert(_ note: Model.Note) async {
        switch await svc.upsert(note: note) {
            case .success:
                await action { Notes.Business.Action.upsertNoteSuccess(note: note) }
            case let .failure(err):
                await actions(.concurrently) {
                    Notes.Business.Action.upsertNoteFail(err: err)
                    ErrorHandling.Business.Effect.track(error: err)
                }
        }
    }

    private func delete(_ note: Model.Note) async {
        switch await svc.delete(noteId: note.id) {
            case .success:
                await action { Notes.Business.Action.deleteNoteSuccess(note: note) }
            case let .failure(err):
                await actions(.concurrently) {
                    Notes.Business.Action.deleteNoteFail(err: err)
                    ErrorHandling.Business.Effect.track(error: err)
                }
        }
    }
}
