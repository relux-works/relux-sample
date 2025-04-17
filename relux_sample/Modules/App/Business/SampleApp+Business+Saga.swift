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
            case .runLogoutFlow: await self.store.cleanup()
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
}
