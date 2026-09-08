extension Notes.UI.Model {
    enum Page: NavPathComponent {
        case list
        case details(id: Notes.Business.Model.Note.Id)
        case create
        case edit(id: Notes.Business.Model.Note.Id)
    }
}
