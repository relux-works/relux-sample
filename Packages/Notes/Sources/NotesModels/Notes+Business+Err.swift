import Foundation

extension Notes.Business {
    public enum Err: Error, Sendable {
        case notImplemented
        case obtainFailed(cause: Error)
        case upsertFailed(note: Model.Note, cause: Error)
        case deleteFailed(noteId: Model.Note.Id, cause: Error)
    }
}

extension Notes.Business.Err: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(localizedDescription)
    }
}

extension Notes.Business.Err: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.localizedDescription == rhs.localizedDescription
    }
}
