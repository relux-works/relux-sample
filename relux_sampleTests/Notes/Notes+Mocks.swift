import SwiftMocks
@testable import relux_sample

extension Notes.Business {
    @Mock
    final class ServiceMock: IService, @unchecked Sendable {
        func getNotes() async -> Result<[Note], Err> {
            await mock.getNotes()
        }
        
        func upsert(note: Model.Note) async -> Result<Void, Err> {
            await mock.upsert(note: note)
        }
        
        func delete(noteId: Model.Note.Id) async -> Result<Void, Err> {
            await mock.delete(noteId: noteId)
        }
    }
}
