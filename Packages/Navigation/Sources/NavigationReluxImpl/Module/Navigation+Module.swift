import Relux
import SwiftUIRelux
import ReluxRouter
import NavigationReluxInt

extension Navigation {
    /// Generic navigation module. Host app provides Route/Modal types.
    @MainActor
    public struct Module<
        Route: Relux.Navigation.PathComponent,
        Modal: Relux.Navigation.ModalComponent
    >: Relux.Module {

        public let states: [any Relux.AnyState]
        public let sagas: [any Relux.Saga] = []
        public let actionRelays: [any Relux.ActionRelaying]

        public let router: Relux.Navigation.ProjectingRouter<Route>
        public let modalRouter: Navigation.Business.ModalRouter<Modal>

        public init(initialPath: [Route]) {
            let router = Relux.Navigation.ProjectingRouter<Route>(pages: initialPath)
            let modalRouter = Navigation.Business.ModalRouter<Modal>()

            self.router = router
            self.modalRouter = modalRouter
            self.states = [router, modalRouter]

            let actions = NavigationActions<Route, Modal>(
                go: { route in
                    Relux.Navigation.ProjectingRouter<Route>.Action.push(route)
                },
                replace: { route in
                    Relux.Navigation.ProjectingRouter<Route>.Action.set([route])
                },
                back: {
                    Relux.Navigation.ProjectingRouter<Route>.Action.removeLast()
                },
                root: {
                    Relux.Navigation.ProjectingRouter<Route>.Action.set([])
                },
                present: { modal in
                    Navigation.Business.ModalRouter<Modal>.Action.present(page: modal)
                },
                dismiss: {
                    Navigation.Business.ModalRouter<Modal>.Action.dismiss
                }
            )

            self.actionRelays = [
                Relux.UI.ActionRelay(actions)
            ]
        }
    }
}
