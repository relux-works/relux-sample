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
        // Each service lifetime starts with these examples. Nothing is persisted or sent over a network.
        private var notes: Dictionary<DTO.Note.Id, DTO.Note> = [
            .init(id: .init(), date: .now, title: "Welcome to Notes",
                  content: "Capture an idea, edit it, then try searching for a word in its title or body. Changes stay in memory and reset when the app restarts."),
            .init(id: .init(), date: .now.add(days: -1), title: "Weekend checklist",
                  content: "Pick up coffee beans\nTake a walk by the river\nBring a notebook"),
            .init(id: .init(), date: .now.add(days: -2), title: "How this demo works",
                  content: "A container dispatches an effect. The Notes flow calls a service, then dispatches an action. The reducer updates business state and the UI projection refreshes the screen.")
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
