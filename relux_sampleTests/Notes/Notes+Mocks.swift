@testable import relux_sample

extension Notes.Business {
    final class ServiceMock: IService, @unchecked Sendable {
        private(set) var obtainNotesCallCount = 0
        private(set) var upsertNotesCallCount = 0
        private(set) var deleteNotesCallCount = 0

        var obtainNotesHandler: (() -> Result<[Note], Err>)?
        var upsertNotesHandler: ((Note) -> Result<Void, Err>)?
        var deleteNotesHandler: ((Note.Id) -> Result<Void, Err>)?

        func getNotes() async -> Result<[Note], Err> {
            obtainNotesCallCount += 1
            return obtainNotesHandler!()
        }

        func upsert(note: Note) async -> Result<Void, Err> {
            upsertNotesCallCount += 1
            return upsertNotesHandler!(note)
        }

        func delete(noteId: Note.Id) async -> Result<Void, Err> {
            deleteNotesCallCount += 1
            return deleteNotesHandler!(noteId)
        }
    }
}
