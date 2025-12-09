import AuthReluxInt
import Relux

extension SampleApp.Business {
    protocol ISaga: Relux.Saga {}
}

extension SampleApp.Business {
    actor Saga {
        private let store: Relux.Store

        init(
            store: Relux.Store
        ) {
            self.store = store
        }
    }
}

extension SampleApp.Business.Saga: SampleApp.Business.ISaga {
    func apply(_ effect: any Relux.Effect) async {
        switch effect as? SampleApp.Business.Effect {
            case .none: break
            case .setAppContext: await setAppContext()
        }

        switch effect as? Auth.Business.Effect {
            case .runLogoutFlow: await cleanupAppCache()
            default: break
        }
    }
}

extension SampleApp.Business.Saga {
    private func setAppContext() async {
        await actions {
            AppRouter.Action.set([.auth(page: .localAuth)])
        }
    }

    private func cleanupAppCache() async {
        // Wipe every state in the store except those listed in `exclusions`.
        // AppRouter is excluded so the navigation stack survives logout.
        await self.store.cleanup(
            exclusions: [AppRouter.self]
        )
    }
}
