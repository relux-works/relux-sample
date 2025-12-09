import Relux
import Auth
@testable import relux_sample

extension Notes.Business.Action {
    enum TestableAction: Equatable {
        typealias Model = Notes.Business.Model

        case obtainNotesSuccess(notes: [Model.Note])
        case obtainNotesFail(err: String)

        case upsertNoteSuccess(note: Model.Note)
        case upsertNoteFail(err: String)

        case deleteNoteSuccess(note: Model.Note)
        case deleteNoteFail(err: String)
    }
}

extension Notes.Business.Action {
    var asTestableAction: TestableAction {
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
