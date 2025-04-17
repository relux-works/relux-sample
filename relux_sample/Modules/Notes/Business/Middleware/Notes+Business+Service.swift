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
        private var notes: Dictionary<Note.Id, Note> = [
            Note(id: .init(), createdAt: .now, title: "title 1", content: "content 1"),
            Note(id: .init(), createdAt: .now.add(minutes: -1), title: "title 2", content: "content 2"),
            Note(id: .init(), createdAt: .now.add(days: -1), title: "title 3", content: "content 3"),
            Note(id: .init(), createdAt: .now.add(days: -2), title: "title 4", content: "content 4"),
            Note(id: .init(), createdAt: .now.add(days: -2).add(hours: -2).add(minutes: -2), title: "title 5", content: "content 5"),
        ].keyed(by: \.id)
    }
}

extension Notes.Business.Service: Notes.Business.IService {
    func getNotes() async -> Result<[Notes.Business.Model.Note], Notes.Business.Err> {
        .success(notes.values.sorted())
    }
    
    func upsert(note: Notes.Business.Model.Note) async -> Result<Void, Notes.Business.Err> {
        self.notes[note.id] = note
        return .success(())
    }
    
    func delete(noteId: Notes.Business.Model.Note.Id) -> Result<Void, Notes.Business.Err> {
        self.notes.removeValue(forKey: noteId)
        return .success(())
    }
}
