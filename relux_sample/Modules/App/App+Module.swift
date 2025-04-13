import SwiftIoC

extension SampleApp {
    protocol IModule: Relux.Module {
    }
}

extension SampleApp {
    @MainActor
    struct Module: IModule {
        private static let ioc: IoC = Self.buildIoC()

        let states: [any Relux.AnyState] = []
        let sagas: [any Relux.Saga]

        init() {
            self.sagas = [
                Self.ioc.get(by: SampleApp.Business.ISaga.self)!
            ]
        }
    }
}

extension SampleApp.Module {
    private static func buildIoC() -> IoC {
        let ioc: IoC = .init(logger: IoC.Logger(enabled: false))

        ioc.register(SampleApp.Business.ISaga.self, resolver: buildSaga)

        return ioc
    }



    private static func buildSaga() -> SampleApp.Business.ISaga {
        SampleApp.Business.Saga()
    }
}
