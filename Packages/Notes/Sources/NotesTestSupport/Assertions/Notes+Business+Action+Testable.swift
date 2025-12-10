import NotesReluxInt

extension Notes.Business.Action {
    public enum Testable: Equatable {
        case obtainNotesSuccess(notes: [Notes.Business.Model.Note])
        case obtainNotesFail(err: String)
        case upsertNoteSuccess(note: Notes.Business.Model.Note)
        case upsertNoteFail(err: String)
        case deleteNoteSuccess(note: Notes.Business.Model.Note)
        case deleteNoteFail(err: String)
    }

    public var testable: Testable {
        switch self {
            case let .obtainNotesSuccess(notes): .obtainNotesSuccess(notes: notes)
            case let .obtainNotesFail(err): .obtainNotesFail(err: err.localizedDescription)
            case let .upsertNoteSuccess(note): .upsertNoteSuccess(note: note)
            case let .upsertNoteFail(err): .upsertNoteFail(err: err.localizedDescription)
            case let .deleteNoteSuccess(note): .deleteNoteSuccess(note: note)
            case let .deleteNoteFail(err): .deleteNoteFail(err: err.localizedDescription)
        }
    }
}
