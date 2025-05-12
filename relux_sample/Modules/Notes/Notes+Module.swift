import SwiftIoC

// relux module with resolved dependencies
extension Notes {
    struct Module: Relux.Module {
        private let ioc: IoC

        var states: [any Relux.AnyState]
        var sagas: [any Relux.Saga]

        init() async {
            self.ioc = Self.buildIoC()
            self.states = [
                self.ioc.get(by: Notes.Business.State.self)!,
                await self.ioc.getAsync(by: Notes.UI.State.self)!
            ]
            self.sagas = [
                self.ioc.get(by: Notes.Business.IFlow.self)!
            ]
        }
    }
}

extension Notes.Module {
    static func buildIoC() -> IoC {
        let ioc: IoC = .init(logger: IoC.Logger(enabled: false))

        ioc.register(Notes.Business.State.self, lifecycle: .container, resolver: buildBusinessState)
        ioc.register(Notes.UI.State.self, lifecycle: .container, resolver: { await buildUIState(ioc: ioc) })
        ioc.register(Notes.Business.IService.self, lifecycle: .container, resolver: { buildSvc(ioc: ioc) })
        ioc.register(Notes.Data.Api.IFetcher.self, lifecycle: .container, resolver: { buildFetcher(ioc: ioc) })
        ioc.register(Notes.Business.IFlow.self, lifecycle: .container, resolver: { buildFlow(ioc: ioc) })

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

    private static func buildSvc(ioc: IoC) -> Notes.Business.IService {
        Notes.Business.Service(
            fetcher: ioc.get(by: Notes.Data.Api.IFetcher.self)!
        )
    }

    private static func buildFetcher(ioc: IoC) -> Notes.Data.Api.IFetcher {
        Notes.Data.Api.Fetcher()
    }

    private static func buildFlow(ioc: IoC) -> Notes.Business.IFlow {
        Notes.Business.Flow(
            svc: ioc.get(by: Notes.Business.IService.self)!
        )
    }
}
