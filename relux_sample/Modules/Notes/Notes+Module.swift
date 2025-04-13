import SwiftIoC

extension Notes {
    struct Module: Relux.Module {
        private static let ioc: IoC = Self.buildIoC()

        var states: [any Relux.AnyState]
        var sagas: [any Relux.Saga]
        
        init(

        ) async {
            self.states = [
                await Self.ioc.get(by: Notes.Business.State.self)!,
                await Self.ioc.get(by: Notes.UI.State.self)!
            ]
            self.sagas = [
                await Self.ioc.get(by: Notes.Business.ISaga.self)!
            ]
        }
    }
}

extension Notes.Module {
    static func buildIoC() -> IoC {
        let ioc: IoC = .init(logger: IoC.Logger(enabled: false))

        ioc.register(Notes.Business.State.self, lifecycle: .container, resolver: buildBusinessState)
        ioc.register(Notes.UI.State.self, lifecycle: .container, resolver: buildUIState)
        ioc.register(Notes.Business.IService.self, lifecycle: .container, resolver: buildSvc)
        ioc.register(Notes.Business.ISaga.self, lifecycle: .container, resolver: buildSaga)

        return ioc
    }

    private static func buildBusinessState() -> Notes.Business.State {
        Notes.Business.State()
    }

    private static func buildUIState() async -> Notes.UI.State {
        await Notes.UI.State(
            state: ioc.get(by: Notes.Business.State.self)!
        )
    }

    private static func buildSvc() -> Notes.Business.IService {
        Notes.Business.Service()
    }

    private static func buildSaga() -> Notes.Business.ISaga {
        Notes.Business.Saga(
            svc: ioc.get(by: Notes.Business.IService.self)!
        )
    }
}
