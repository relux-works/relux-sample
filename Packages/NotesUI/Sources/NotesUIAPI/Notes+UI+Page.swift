import NotesReluxInt
import Relux

extension Notes.UI.Model {
    public enum Page: Relux.Navigation.PathComponent {
        case list
        case details(id: Notes.Business.Model.Note.Id)
        case create
        case edit(note: Notes.Business.Model.Note)
    }
}
