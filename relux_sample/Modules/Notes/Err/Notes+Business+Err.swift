extension Notes.Business {
    enum Err: Error {
        case notImplemented
        case obtainFailed(cause: Error)
        case upsertFailed(note: Model.Note, cause: Error)
        case deleteFailed(noteId: Model.Note.Id, cause: Error)
    }
}

extension Notes.Business.Err: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(localizedDescription)
    }
}
extension Notes.Business.Err: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.localizedDescription == rhs.localizedDescription
    }
}
