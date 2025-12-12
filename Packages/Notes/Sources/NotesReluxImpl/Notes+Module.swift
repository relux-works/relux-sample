import NotesReluxInt
import NotesServiceInt
import Relux
import SwiftUIRelux
import SwiftIoC

extension Notes {
    public struct Module: Relux.Module {
        private let ioc: IoC

        public let states: [any Relux.AnyState]
        public let sagas: [any Relux.Saga]
        public let actionRelays: [any Relux.ActionRelaying]

        public init(
            serviceFactory: @Sendable @escaping () -> Notes.Business.IService,
            router: any Notes.Business.IRouter,
            onError: (@Sendable (Notes.Business.Err) async -> Void)? = nil
        ) async {
            self.ioc = Self.buildIoC(
                serviceFactory: serviceFactory,
                onError: onError
            )

            self.states = [
                ioc.get(by: Notes.Business.IState.self)!,
                await ioc.getAsync(by: Notes.UI.State.self)!
            ]

            self.sagas = [
                await ioc.getAsync(by: Notes.Business.IFlow.self)!
            ]

            let routerActions = Notes.Business.RouterActions(router: router)
            self.actionRelays = [
                await Relux.UI.ActionRelay(routerActions)
            ]
        }
    }
}

private extension Notes.Module {
    static func buildIoC(
        serviceFactory: @escaping () -> Notes.Business.IService,
        onError: (@Sendable (Notes.Business.Err) async -> Void)?
    ) -> IoC {
        let ioc = IoC(logger: IoC.Logger(enabled: false))

        ioc.register(Notes.Business.State.self, lifecycle: .container, resolver: buildBusinessState)
        ioc.register(Notes.Business.IState.self, lifecycle: .container, resolver: { ioc.get(by: Notes.Business.State.self)! })
        ioc.register(Notes.UI.State.self, lifecycle: .container, resolver: { await buildUIState(ioc: ioc) })
        ioc.register(Notes.Business.IService.self, lifecycle: .container, resolver: { serviceFactory() })
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
