import NotesReluxInt
import SwiftUIRelux
extension Notes.UI.Model {
    enum Page: NavPathComponent {
        case list
        case details(id: Notes.Business.Model.Note.Id)
        case create
        case edit(note: Notes.Business.Model.Note)
    }
}