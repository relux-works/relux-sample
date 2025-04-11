extension Notes.Business {
    protocol IService: Sendable {
        func getNotes() async -> Result<[Model.Note], Err>
        func upsert(note: Model.Note) async -> Result<Void, Err>
        func delete(noteId: Model.Note.Id) async -> Result<Void, Err>
    }
}

extension Notes.Business {
    actor Service {
        private var notes: Dictionary<Model.Note.Id, Model.Note> = [:]
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
