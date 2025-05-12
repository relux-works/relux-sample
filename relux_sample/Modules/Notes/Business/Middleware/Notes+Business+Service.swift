extension Notes.Business {
    protocol IService: Sendable {
        typealias Note = Notes.Business.Model.Note
        typealias Err = Notes.Business.Err

        func getNotes() async -> Result<[Note], Err>
        func upsert(note: Note) async -> Result<Void, Err>
        func delete(noteId: Note.Id) async -> Result<Void, Err>
    }
}

extension Notes.Business {
    actor Service {
        private let fetcher: Notes.Data.Api.IFetcher

        init(
            fetcher: Notes.Data.Api.IFetcher
        ) {
            self.fetcher = fetcher
        }
    }
}

extension Notes.Business.Service: Notes.Business.IService {
    func getNotes() async -> Result<[Note], Err> {
        switch await self.fetcher.getNotes() {
            case let .success(notes): .success(
                notes
                    .map { Note(from: $0) } 
                    .sorted()
            )
            case let .failure(err): .failure(err)
        }
    }
    
    func upsert(note: Notes.Business.Model.Note) async -> Result<Void, Notes.Business.Err> {
        await self.fetcher.upsert(note: note.asDto)

        // uncomment this to check "Notes.Flow.upsert" result completeness
//        return .failure(.notImplemented)
    }
    
    func delete(noteId: Notes.Business.Model.Note.Id) async -> Result<Void, Notes.Business.Err> {
        await self.fetcher.deletetNote(by: noteId)
    }
}
