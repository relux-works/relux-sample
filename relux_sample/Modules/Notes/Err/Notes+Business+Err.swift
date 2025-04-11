extension Notes.Business {
    enum Err: Error {
        case notImplemented
        case obtainFailed(cause: Error)
        case upsertFailed(note: Model.Note, cause: Error)
        case deleteFailed(noteId: Model.Note.Id, cause: Error)
    }
}
