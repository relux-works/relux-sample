import SwiftIoC

extension Auth {
    protocol IModule: Relux.Module {}
}

extension Auth {
    @MainActor
    struct Module: IModule {
        private static let ioc: IoC = Self.buildIoC()

        let states: [any Relux.AnyState]
        let sagas: [any Relux.Saga]

        init() {
            self.states = [
                Self.ioc.get(by: Auth.Business.IState.self)!
            ]
            self.sagas = [
                Self.ioc.get(by: Auth.Business.ISaga.self)!
            ]
        }
    }
}

extension Auth.Module {
    private static func buildIoC() -> IoC {
        let ioc: IoC = .init(logger: IoC.Logger(enabled: false))

        ioc.register(Auth.Business.IState.self, resolver: buildState)
        ioc.register(Auth.Business.IService.self, resolver: buildSvc)
        ioc.register(Auth.Business.ISaga.self, resolver: buildSaga)

        return ioc
    }

    private static func buildState() -> Auth.Business.IState {
        Auth.Business.State()
    }

    private static func buildSvc() -> Auth.Business.IService {
        Auth.Business.Service()
    }

    private static func buildSaga() -> Auth.Business.ISaga {
        Auth.Business.Saga(
            svc: ioc.get(by: Auth.Business.IService.self)!
        )
    }
}
