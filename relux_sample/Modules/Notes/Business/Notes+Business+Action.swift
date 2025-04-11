extension Notes.Business {
    enum Action: Relux.Action {
        case obtainNotesSuccess(notes: [Model.Note])
        case obtainNotesFail(err: Err)

        case upsertNoteSuccess(note: Model.Note)
        case upsertNoteFail(err: Err)

        case deleteNoteSuccess(note: Model.Note)
        case deleteNoteFail(err: Err)
    }
}
