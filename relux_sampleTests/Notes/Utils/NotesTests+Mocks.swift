@testable import relux_sample

extension NotesTests.Business {
        /// Mock implementation of Notes.Business.IService for testing
    final class ServiceMock: Notes.Business.IService, @unchecked Sendable {
            /// Tracks the number of times the corresponding method was called
        private(set) var obtainNotesCallCount = 0
            /// Tracks the number of times the corresponding method was called
        private(set) var upsertNotesCallCount = 0
            /// Tracks the number of times the corresponding method was called
        private(set) var deleteNotesCallCount = 0

            /// Closure that simulates the method's result
        var obtainNotesHandler: (() -> Result<[Note], Err>)?
            /// Closure that simulates the method's result
        var upsertNotesHandler: ((Note) -> Result<Void, Err>)?
            /// Closure that simulates the method's result
        var deleteNotesHandler: ((Note.Id) -> Result<Void, Err>)?

            /// Mock implementation of IService.getNotes
            /// Increments the call counter and invokes the handler
        func getNotes() async -> Result<[Note], Err> {
            obtainNotesCallCount += 1
            return obtainNotesHandler!()
        }

            /// Mock implementation of IService.upsert
            /// Increments the call counter and invokes the handler
        func upsert(note: Note) async -> Result<Void, Err> {
            upsertNotesCallCount += 1
            return upsertNotesHandler!(note)
        }

            /// Mock implementation of IService.delete
            /// Increments the call counter and invokes the handler
        func delete(noteId: Note.Id) async -> Result<Void, Err> {
            deleteNotesCallCount += 1
            return deleteNotesHandler!(noteId)
        }
    }
}
