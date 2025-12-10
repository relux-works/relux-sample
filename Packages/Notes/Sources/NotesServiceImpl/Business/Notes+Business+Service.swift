import Foundation
import NotesModels
import NotesServiceInt

extension Notes.Business {
    public actor Service {
        public typealias Model = Notes.Business.Model

        private let fetcher: Notes.Data.Api.IFetcher

        public init(fetcher: Notes.Data.Api.IFetcher) {
            self.fetcher = fetcher
        }
    }
}

extension Notes.Business.Service: Notes.Business.IService {
    public func getNotes() async -> Result<[Note], Err> {
        switch await fetcher.getNotes() {
            case let .success(dtoNotes):
                return .success(dtoNotes.map(Model.Note.init(from:)))
            case let .failure(err):
                return .failure(err)
        }
    }

    public func upsert(note: Note) async -> Result<Void, Err> {
        switch await fetcher.upsert(note: note.asDto) {
            case .success: return .success(())
            case let .failure(err): return .failure(.upsertFailed(note: note, cause: err))
        }
    }

    public func delete(noteId: Note.Id) async -> Result<Void, Err> {
        switch await fetcher.deletetNote(by: noteId) {
            case .success: return .success(())
            case let .failure(err): return .failure(.deleteFailed(noteId: noteId, cause: err))
        }
    }
}
