import SwiftIoC

extension ErrorHandling {
    protocol IModule: Relux.Module {}
}

extension ErrorHandling {
    struct Module: IModule {
        private let ioc: IoC = Self.buildIoC()

        let states: [any Relux.AnyState] = []
        var sagas: [any Relux.Saga]
        
        init() {
            self.sagas = [
                self.ioc.get(by: ErrorHandling.Business.ISaga.self)!
            ]
        }
    }
}

extension ErrorHandling.Module {
    private static func buildIoC() -> IoC {
        let ioc: IoC = .init(logger: IoC.Logger(enabled: false))

        ioc.register(ErrorHandling.Business.IService.self, lifecycle: .container, resolver: buildSvc)
        ioc.register(ErrorHandling.Business.ISaga.self, lifecycle: .container, resolver: { buildSaga(ioc: ioc) })

        return ioc
    }

    private static func buildSvc() -> ErrorHandling.Business.IService {
        ErrorHandling.Business.Service()
    }

    private static func buildSaga(ioc: IoC) -> ErrorHandling.Business.ISaga {
        ErrorHandling.Business.Saga(
            svc: ioc.get(by: ErrorHandling.Business.IService.self)!
        )
    }
}
