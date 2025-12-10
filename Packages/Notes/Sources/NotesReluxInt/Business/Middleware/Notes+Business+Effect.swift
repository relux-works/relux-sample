import NotesModels
import Relux

extension Notes.Business {
    public enum Effect: Relux.Effect {
        case obtainNotes
        case upsert(note: Model.Note)
        case delete(note: Model.Note)
    }
}
