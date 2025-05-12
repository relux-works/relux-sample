extension Notes.Data.Api {
    protocol IFetcher: Sendable {
        typealias Err = Notes.Business.Err
        typealias DTO = Notes.Data.Api.DTO

        func getNotes() async -> Result<[DTO.Note], Err>
        func upsert(note: DTO.Note) async -> Result<Void, Err>
        func deletetNote(by id: DTO.Note.Id) async -> Result<Void, Err>
    }
}

extension Notes.Data.Api {
    actor Fetcher {
        private var notes: Dictionary<DTO.Note.Id, DTO.Note> = [
            .init(id: .init(), date: .now, title: "title 1", content: "content 1"),
            .init(id: .init(), date: .now.add(minutes: -1), title: "title 2", content: "content 2"),
            .init(id: .init(), date: .now.add(days: -1), title: "title 3", content: "content 3"),
            .init(id: .init(), date: .now.add(days: -2), title: "title 4", content: "content 4"),
            .init(id: .init(), date: .now.add(days: -2).add(hours: -2).add(minutes: -2), title: "title 5", content: "content 5"),
        ].keyed(by: \.id)
    }
}

extension Notes.Data.Api.Fetcher: Notes.Data.Api.IFetcher {
    func getNotes() async -> Result<[DTO.Note], Err> {
        .success(Array(notes.values))
    }

    func upsert(note: DTO.Note) async -> Result<Void, Err> {
        self.notes[note.id] = note
        return .success(())
    }
    
    func deletetNote(by id: DTO.Note.Id) async -> Result<Void, Err> {
        self.notes.removeValue(forKey: id)
        return .success(())
    }
    

}


extension Notes.Data.Api {
    actor TestFetcher {
        private var notes: Dictionary<DTO.Note.Id, DTO.Note> = [
            .init(id: .init(), date: .now, title: "title 1", content: "content 1"),
            .init(id: .init(), date: .now.add(days: -2).add(hours: -2).add(minutes: -2), title: "title 5", content: "content 5"),
        ].keyed(by: \.id)
    }
}

extension Notes.Data.Api.TestFetcher: Notes.Data.Api.IFetcher {
    func getNotes() async -> Result<[DTO.Note], Err> {
        .success(Array(notes.values))
    }

    func upsert(note: DTO.Note) async -> Result<Void, Err> {
        self.notes[note.id] = note
        return .success(())
    }

    func deletetNote(by id: DTO.Note.Id) async -> Result<Void, Err> {
        self.notes.removeValue(forKey: id)
        return .success(())
    }
}
