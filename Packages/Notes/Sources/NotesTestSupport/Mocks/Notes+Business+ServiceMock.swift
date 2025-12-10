import NotesModels
import NotesServiceInt

extension Notes.Business {
    public final class ServiceMock: Notes.Business.IService, @unchecked Sendable {
        public private(set) var obtainNotesCallCount = 0
        public private(set) var upsertNotesCallCount = 0
        public private(set) var deleteNotesCallCount = 0

        public var obtainNotesHandler: (() -> Result<[Note], Err>)?
        public var upsertNotesHandler: ((Note) -> Result<Void, Err>)?
        public var deleteNotesHandler: ((Note.Id) -> Result<Void, Err>)?

        public init() {}

        public func getNotes() async -> Result<[Note], Err> {
            obtainNotesCallCount += 1
            guard let handler = obtainNotesHandler else { return .failure(.notImplemented) }
            return handler()
        }

        public func upsert(note: Note) async -> Result<Void, Err> {
            upsertNotesCallCount += 1
            guard let handler = upsertNotesHandler else { return .failure(.notImplemented) }
            return handler(note)
        }

        public func delete(noteId: Note.Id) async -> Result<Void, Err> {
            deleteNotesCallCount += 1
            guard let handler = deleteNotesHandler else { return .failure(.notImplemented) }
            return handler(noteId)
        }

        // Convenience stubs
        public func stubObtainSuccess(_ notes: [Note]) {
            obtainNotesHandler = { .success(notes) }
        }

        public func stubObtainFailure(_ err: Err) {
            obtainNotesHandler = { .failure(err) }
        }

        public func stubUpsertSuccess() {
            upsertNotesHandler = { _ in .success(()) }
        }

        public func stubUpsertFailure(_ err: Err) {
            upsertNotesHandler = { _ in .failure(err) }
        }

        public func stubDeleteSuccess() {
            deleteNotesHandler = { _ in .success(()) }
        }

        public func stubDeleteFailure(_ err: Err) {
            deleteNotesHandler = { _ in .failure(err) }
        }
    }
}
