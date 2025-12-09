import AuthModels
import AuthReluxInt
import AuthServiceInt
import AuthServiceImpl
import Relux
import SwiftIoC

extension Auth {
    public protocol IModule: Relux.Module {}
}

// relux module with resolved dependencies
extension Auth {
    @MainActor
    public struct Module: IModule {
        private let ioc: IoC

        public let states: [any Relux.AnyState]
        public let sagas: [any Relux.Saga]

        public init(router: Auth.Business.IRouter) {
            let container = Self.buildIoC(router: router)
            self.ioc = container

            self.states = [
                container.get(by: Auth.Business.IState.self)!
            ]
            self.sagas = [
                container.get(by: Auth.Business.ISaga.self)!
            ]
        }
    }
}

extension Auth.Module {
    private static func buildIoC(router: Auth.Business.IRouter) -> IoC {
        let ioc: IoC = .init(logger: IoC.Logger(enabled: false))

        ioc.register(Auth.Business.IRouter.self, lifecycle: .container, resolver: { router })
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
            svc: ioc.get(by: Auth.Business.IService.self)!,
            router: ioc.get(by: Auth.Business.IRouter.self)!
        )
    }
}
