import NotesModels

extension Notes.Business {
    public protocol IService: Sendable {
        typealias Err = Notes.Business.Err
        typealias Note = Notes.Business.Model.Note

        func getNotes() async -> Result<[Note], Err>
        func upsert(note: Note) async -> Result<Void, Err>
        func delete(noteId: Note.Id) async -> Result<Void, Err>
    }
}
