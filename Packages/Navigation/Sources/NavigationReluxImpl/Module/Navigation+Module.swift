import Relux
import SwiftUIRelux
import NavigationReluxInt

extension Navigation {
    @MainActor
    public struct Module: Relux.Module {
        public let states: [any Relux.AnyState]
        public let sagas: [any Relux.Saga] = []
        public let actionRelays: [any Relux.ActionRelaying]

        /// The main router instance — exposed for NavigationStack binding in App.
        public let router: AppRouter

        /// The modal router instance — exposed for sheet binding in App.
        public let modalRouter: Navigation.Business.ModalRouter

        public init() {
            let router = AppRouter(pages: [.splash])
            let modalRouter = Navigation.Business.ModalRouter()

            self.router = router
            self.modalRouter = modalRouter
            self.states = [router, modalRouter]

            // Build AppNavigation with action factories
            let appNavigation = AppNavigation(
                go: { destination in
                    makeRouterAction(for: destination)
                },
                replace: { destination in
                    makeRouterReplaceAction(for: destination)
                },
                present: { page in
                    Navigation.Business.ModalRouter.Action.present(page: page)
                },
                dismiss: {
                    Navigation.Business.ModalRouter.Action.dismiss
                }
            )

            // Register ActionRelay for auto-injection into SwiftUI Environment
            self.actionRelays = [
                Relux.UI.ActionRelay(appNavigation)
            ]
        }
    }
}
