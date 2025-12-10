import NotesModels
import NotesReluxInt
import NotesServiceInt
import Relux

extension Notes.Business {
    public actor Flow: Notes.Business.IFlow {
        typealias Model = Notes.Business.Model

        public let dispatcher: Relux.Dispatcher
        private let svc: Notes.Business.IService
        private let onError: (@Sendable (Notes.Business.Err) async -> Void)?

        public init(
            dispatcher: Relux.Dispatcher? = nil,
            svc: Notes.Business.IService,
            onError: (@Sendable (Notes.Business.Err) async -> Void)? = nil
        ) async {
            if let dispatcher {
                self.dispatcher = dispatcher
            } else {
                self.dispatcher = await Self.defaultDispatcher
            }
            self.svc = svc
            self.onError = onError
        }

        public func apply(_ effect: any Relux.Effect) async -> Relux.Flow.Result {
            switch effect as? Notes.Business.Effect {
                case .none: return .success
                case .obtainNotes: return await obtainNotes()
                case let .upsert(note): return await upsert(note)
                case let .delete(note): return await delete(note)
            }
        }
    }
}

private extension Notes.Business.Flow {
    func obtainNotes() async -> Relux.Flow.Result {
        switch await svc.getNotes() {
            case let .success(notes):
                await actions {
                    Notes.Business.Action.obtainNotesSuccess(notes: notes)
                }
                return .success

            case let .failure(err):
                async let track: Void = trackError(err)
                await actions {
                    Notes.Business.Action.obtainNotesFail(err: err)
                }
                _ = await track
                return .success
        }
    }

    func upsert(_ note: Model.Note) async -> Relux.Flow.Result {
        switch await svc.upsert(note: note) {
            case .success:
                await actions {
                    Notes.Business.Action.upsertNoteSuccess(note: note)
                }
                return .success

            case let .failure(err):
                async let track: Void = trackError(err)
                await actions {
                    Notes.Business.Action.upsertNoteFail(err: err)
                }
                _ = await track
                return .failure(err)
        }
    }

    func delete(_ note: Model.Note) async -> Relux.Flow.Result {
        switch await svc.delete(noteId: note.id) {
            case .success:
                await actions {
                    Notes.Business.Action.deleteNoteSuccess(note: note)
                }
                return .success

            case let .failure(err):
                async let track: Void = trackError(err)
                await actions {
                    Notes.Business.Action.deleteNoteFail(err: err)
                }
                _ = await track
                return .failure(err)
        }
    }

    func trackError(_ err: Notes.Business.Err) async {
        guard let onError else { return }
        await onError(err)
    }
}
