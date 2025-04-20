import SwiftIoC

// relux module with resolved dependencies
extension Notes {
    struct Module: Relux.Module {
        private let ioc: IoC = Self.buildIoC()

        var states: [any Relux.AnyState]
        var sagas: [any Relux.Saga]
        
        init(

        ) async {
            self.states = [
                self.ioc.get(by: Notes.Business.State.self)!,
                await self.ioc.getAsync(by: Notes.UI.State.self)!
            ]
            self.sagas = [
                self.ioc.get(by: Notes.Business.ISaga.self)!
            ]
        }
    }
}

extension Notes.Module {
    static func buildIoC() -> IoC {
        let ioc: IoC = .init(logger: IoC.Logger(enabled: false))

        ioc.register(Notes.Business.State.self, lifecycle: .container, resolver: buildBusinessState)
        ioc.register(Notes.UI.State.self, lifecycle: .container, resolver: { await buildUIState(ioc: ioc) })
        ioc.register(Notes.Business.IService.self, lifecycle: .container, resolver: buildSvc)
        ioc.register(Notes.Business.ISaga.self, lifecycle: .container, resolver: { buildSaga(ioc: ioc) })

        return ioc
    }

    private static func buildBusinessState() -> Notes.Business.State {
        Notes.Business.State()
    }

    private static func buildUIState(ioc: IoC) async -> Notes.UI.State {
        await Notes.UI.State(
            state: ioc.get(by: Notes.Business.State.self)!
        )
    }

    private static func buildSvc() -> Notes.Business.IService {
        Notes.Business.Service()
    }

    private static func buildSaga(ioc: IoC) -> Notes.Business.ISaga {
        Notes.Business.Saga(
            svc: ioc.get(by: Notes.Business.IService.self)!
        )
    }
}
