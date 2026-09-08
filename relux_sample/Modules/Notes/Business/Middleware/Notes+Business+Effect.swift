
extension Notes.Business {
    enum Effect: Relux.Effect {
        case setProtection(noteId: Model.Note.Id, protected: Bool)
        case unlock(noteId: Model.Note.Id)
        case relock(noteId: Model.Note.Id?)
        case obtainNotes
        case upsert(note: Model.Note)
        case delete(note: Model.Note)
    }
}
