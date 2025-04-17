import SwiftIoC

typealias AppPage = Navigation.UI.Model.Page
typealias AppRouter = Relux.Navigation.ProjectingRouter<AppPage>
typealias NavPathComponent = Relux.Navigation.PathComponent

extension AppRouter: Navigation.Business.IRouter {}

extension Navigation {
    protocol IModule: Relux.Module {}
}

extension Navigation.Business {
    protocol IRouter: Relux.HybridState {}
}


extension Navigation {
    @MainActor
    struct Module: IModule {
        private let ioc: IoC = Self.buildIoC()

        let states: [any Relux.AnyState]
        let sagas: [any Relux.Saga] = []

        init() {
            self.states = [
                self.ioc.get(by: Navigation.Business.IRouter.self)!
            ]
        }
    }
}

extension Navigation.Module {
    private static func buildIoC() -> IoC {
        let ioc: IoC = .init(logger: IoC.Logger(enabled: false))

        ioc.register(Navigation.Business.IRouter.self, lifecycle: .container, resolver: buildRouter)

        return ioc
    }
    private static func buildRouter() -> Navigation.Business.IRouter {
        AppRouter(pages: [.splash])
    }
}
