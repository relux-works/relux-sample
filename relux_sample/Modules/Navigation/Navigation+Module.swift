typealias AppPage = Navigation.UI.Model.Page
typealias AppRouter = Relux.Navigation.ProjectingRouter<AppPage>
typealias NavPathComponent = Relux.Navigation.PathComponent

extension Navigation {
    @MainActor
    struct Module: Relux.Module {
        let states: [any Relux.AnyState]
        let sagas: [any Relux.Saga] = []

        init() {
            self.states = [
                AppRouter(pages: [.splash])
            ]
        }
    }
}
