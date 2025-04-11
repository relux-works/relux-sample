
extension Notes.Business {
    enum Effect: Relux.Effect {
        case obtainNotes
        case upsert(note: Model.Note)
        case delete(note: Model.Note)
    }
}
