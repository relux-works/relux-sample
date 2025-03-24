extension SampleApp.Business {
    protocol ISaga: Relux.Saga {}
}

extension SampleApp.Business {
    actor Saga: ISaga {
        func apply(_ effect: any Relux.Effect) async {
            switch effect as? Effect {
                case .none: break
                case .setAppContext: await setAppContext()
            }
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
