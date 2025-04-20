import SwiftIoC

extension SampleApp {
    protocol IModule: Relux.Module {
    }
}

// relux module with resolved dependencies
extension SampleApp {
    @MainActor
    struct Module: IModule {
        private let ioc: IoC

        let states: [any Relux.AnyState] = []
        let sagas: [any Relux.Saga]

        init(
            store: Relux.Store
        ) {
            self.ioc = Self.buildIoC(store: store)

            self.sagas = [
                self.ioc.get(by: SampleApp.Business.ISaga.self)!
            ]
        }
    }
}

extension SampleApp.Module {
    private static func buildIoC(store: Relux.Store) -> IoC {
        let ioc: IoC = .init(logger: IoC.Logger(enabled: false))
        ioc.register(Relux.Store.self, lifecycle: .container, resolver: { store })
        ioc.register(SampleApp.Business.ISaga.self, resolver: { buildSaga(ioc: ioc)})

        return ioc
    }

    private static func buildSaga(ioc: IoC) -> SampleApp.Business.ISaga {
        SampleApp.Business.Saga(
            store: ioc.get(by: Relux.Store.self)!
        )
    }
}
