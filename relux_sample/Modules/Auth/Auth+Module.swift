import SwiftIoC

extension Auth {
    protocol IModule: Relux.Module {}
}

// relux module with resolved dependencies
extension Auth {
    @MainActor
    struct Module: IModule {
        private let ioc: IoC = Self.buildIoC()

        let states: [any Relux.AnyState]
        let sagas: [any Relux.Saga]

        init() {
            self.states = [
                self.ioc.get(by: Auth.Business.IState.self)!
            ]
            self.sagas = [
                self.ioc.get(by: Auth.Business.ISaga.self)!
            ]
        }
    }
}

extension Auth.Module {
    private static func buildIoC() -> IoC {
        let ioc: IoC = .init(logger: IoC.Logger(enabled: false))

        ioc.register(Auth.Business.IState.self, lifecycle: .container, resolver: { buildState() })
        ioc.register(Auth.Business.IService.self, lifecycle: .container, resolver: { buildSvc() })
        ioc.register(Auth.Business.ISaga.self, lifecycle: .container, resolver: { buildSaga(ioc: ioc) })

        return ioc
    }

    private static func buildState() -> Auth.Business.IState {
        Auth.Business.State()
    }

    private static func buildSvc() -> Auth.Business.IService {
        Auth.Business.Service()
    }

    private static func buildSaga(ioc: IoC) -> Auth.Business.ISaga {
        Auth.Business.Saga(
            svc: ioc.get(by: Auth.Business.IService.self)!
        )
    }
}
