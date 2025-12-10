import AuthModels
import AuthReluxInt
import AuthServiceInt
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
        private let serviceFactory: () -> Auth.Business.IService

        public let states: [any Relux.AnyState]
        public let sagas: [any Relux.Saga]

        public init(
            router: Auth.Business.IRouter,
            serviceFactory: @escaping () -> Auth.Business.IService
        ) {
            self.serviceFactory = serviceFactory
            let container = Self.buildIoC(router: router, serviceFactory: serviceFactory)
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
    private static func buildIoC(
        router: Auth.Business.IRouter,
        serviceFactory: @escaping () -> Auth.Business.IService
    ) -> IoC {
        let ioc: IoC = .init(logger: IoC.Logger(enabled: false))

        ioc.register(Auth.Business.IRouter.self, lifecycle: .container, resolver: { router })
        ioc.register(Auth.Business.IState.self, lifecycle: .container, resolver: { buildState() })
        ioc.register(Auth.Business.IService.self, lifecycle: .container, resolver: { buildSvc(factory: serviceFactory) })
        ioc.register(Auth.Business.ISaga.self, lifecycle: .container, resolver: { buildSaga(ioc: ioc) })

        return ioc
    }

    private static func buildState() -> Auth.Business.IState {
        Auth.Business.State()
    }

    private static func buildSvc(factory: () -> Auth.Business.IService) -> Auth.Business.IService {
        factory()
    }

    private static func buildSaga(ioc: IoC) -> Auth.Business.ISaga {
        Auth.Business.Saga(
            svc: ioc.get(by: Auth.Business.IService.self)!,
            router: ioc.get(by: Auth.Business.IRouter.self)!
        )
    }
}
