extension SampleApp.UI.Main.Model {
    enum Page: NavPathComponent {
        case main
        case account
        case notes(_ page: Notes.UI.Model.Page)
    }
}
import NotesReluxInt
