import ReluxRouter

extension Navigation.UI.Model {
    enum Page: NavPathComponent {
        case notes(Notes.UI.Model.Page)
        case settings
        case account
    }
}
