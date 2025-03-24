import ReluxRouter

extension Navigation.UI.Model {
    enum Page: NavPathComponent {
        case splash
        case auth(page: Auth.UI.Model.Page = .logoutFlow)
        case app(page: SampleApp.UI.Main.Model.Page = .main)
    }
}

