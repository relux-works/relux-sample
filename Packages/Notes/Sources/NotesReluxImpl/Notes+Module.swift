import NotesReluxInt
import NotesServiceInt
import NotesServiceImpl
import Relux
import SwiftIoC

extension Notes {
    public struct Module: Relux.Module {
        private let ioc: IoC

        public let states: [any Relux.AnyState]
        public let sagas: [any Relux.Saga]

        public init(
            onError: (@Sendable (Notes.Business.Err) async -> Void)? = nil
        ) async {
            self.ioc = Self.buildIoC(onError: onError)

            self.states = [
                ioc.get(by: Notes.Business.IState.self)!,
                await ioc.getAsync(by: Notes.UI.State.self)!
            ]

            self.sagas = [
                await ioc.getAsync(by: Notes.Business.IFlow.self)!
            ]
        }
    }
}

private extension Notes.Module {
    static func buildIoC(onError: (@Sendable (Notes.Business.Err) async -> Void)?) -> IoC {
        let ioc = IoC(logger: IoC.Logger(enabled: false))

        ioc.register(Notes.Business.State.self, lifecycle: .container, resolver: buildBusinessState)
        ioc.register(Notes.Business.IState.self, lifecycle: .container, resolver: { ioc.get(by: Notes.Business.State.self)! })
        ioc.register(Notes.UI.State.self, lifecycle: .container, resolver: { await buildUIState(ioc: ioc) })
        ioc.register(Notes.Business.IService.self, lifecycle: .container, resolver: { buildService(ioc: ioc) })
        ioc.register(Notes.Data.Api.IFetcher.self, lifecycle: .container, resolver: { buildFetcher() })
        ioc.register(Notes.Business.IFlow.self, lifecycle: .container, resolver: { await buildFlow(ioc: ioc, onError: onError) })

        return ioc
    }

    static func buildBusinessState() -> Notes.Business.State {
        Notes.Business.State()
    }

    static func buildUIState(ioc: IoC) async -> Notes.UI.State {
        await Notes.UI.State(
            state: ioc.get(by: Notes.Business.State.self)!
        )
    }

    static func buildService(ioc: IoC) -> Notes.Business.IService {
        Notes.Business.Service(
            fetcher: ioc.get(by: Notes.Data.Api.IFetcher.self)!
        )
    }

    static func buildFetcher() -> Notes.Data.Api.IFetcher {
        Notes.Data.Api.Fetcher()
    }

    static func buildFlow(
        ioc: IoC,
        onError: (@Sendable (Notes.Business.Err) async -> Void)?
    ) async -> Notes.Business.IFlow {
        await Notes.Business.Flow(
            svc: ioc.get(by: Notes.Business.IService.self)!,
            onError: onError
        )
    }
}
