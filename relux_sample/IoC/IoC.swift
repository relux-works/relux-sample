import AuthModels
import AuthReluxInt
import AuthReluxImpl
import AuthServiceInt
import AuthServiceImpl
import AuthUI
import AuthUIAPI
import NavigationReluxImpl
import SampleAppRoutes
import NotesModels
import NotesReluxInt
import NotesReluxImpl
import NotesServiceImpl
import NotesUI
import NotesUIAPI
import SwiftIoC
import NavigationReluxInt

extension SampleApp {
    // the Registry entity is created for the app purposes
    // we store ioc container with all resolvers in a static field
    // also we put all our builders into its namespace
    @MainActor
    enum Registry {
        static let ioc = IoC(logger: IoC.Logger(enabled: false))
    }
}

// config
extension SampleApp.Registry {
    static func configure() {
        // relux
        ioc.register(Relux.self, lifecycle: .container, resolver: Self.buildRelux)
        ioc.register(Relux.Store.self, lifecycle: .container, resolver: Self.buildReluxStore)
        ioc.register(Relux.RootSaga.self, lifecycle: .container, resolver: Self.buildReluxRootSaga)
        ioc.register(Relux.Logger.self, lifecycle: .container, resolver: Self.buildReluxLogger)

        ioc.register(Auth.Business.IRouter.self, lifecycle: .container, resolver: Self.buildAuthRouter)
        ioc.register(AuthUIProviding.self, lifecycle: .container, resolver: Self.buildAuthUIRouter)
        ioc.register(NotesUIProviding.self, lifecycle: .container, resolver: Self.buildNotesUIRouter)

        ioc.register(SampleApp.Module.self, lifecycle: .container, resolver: Self.buildAppModule)
        ioc.register(ErrorHandling.Module.self, lifecycle: .container, resolver: Self.buildErrHandlingModule)
        ioc.register(AppNavigationModule.self, lifecycle: .container, resolver: Self.buildNavigationModule)
        ioc.register(Auth.Module.self, lifecycle: .container, resolver: Self.buildAuthModule)
        ioc.register(Notes.Module.self, lifecycle: .container, resolver: Self.buildNotesModule)
    }
}

// module builders
extension SampleApp.Registry {
    private static func buildRelux() async -> Relux {
        await Relux.init(
            logger: resolve(Relux.Logger.self),
            appStore: resolve(Relux.Store.self),
            rootSaga: .init()
        )
        .register { @MainActor in
            resolve(ErrorHandling.Module.self)
            resolve(AppNavigationModule.self)
            resolve(SampleApp.Module.self)
            resolve(Auth.Module.self)
            await resolveAsync(Notes.Module.self)
        }
    }


    private static func buildReluxStore() -> Relux.Store {
        Relux.Store()
    }

    private static func buildReluxRootSaga() -> Relux.RootSaga {
        Relux.RootSaga()
    }

    private static func buildReluxLogger() -> Relux.Logger {
        Logger()
    }

    private static func buildAppModule() -> SampleApp.Module {
        SampleApp.Module(
            store: resolve(Relux.Store.self)
        )
    }

    private static func buildErrHandlingModule() -> ErrorHandling.Module {
        ErrorHandling.Module()
    }

    private static func buildNavigationModule() -> AppNavigationModule {
        AppNavigationModule(initialPath: [.splash])
    }

    private static func buildAuthModule() -> Auth.Module {
        Auth.Module(
            router: resolve(Auth.Business.IRouter.self),
            serviceFactory: { Auth.Business.Service() }
        )
    }

    private static func buildNotesModule() async -> Notes.Module {
        await Notes.Module(
            serviceFactory: {
                Notes.Business.Service(
                    fetcher: Notes.Data.Api.Fetcher()
                )
            }
        )
    }

    private static func buildAuthRouter() -> Auth.Business.IRouter {
        AuthRouterAdapter()
    }

    private static func buildAuthUIRouter() -> any AuthUIProviding {
        AuthUIRouter()
    }

    private static func buildNotesUIRouter() -> any NotesUIProviding {
        NotesUIRouter()
    }
}

// resolvers
extension SampleApp.Registry {
    static func optionalResolveAsync<T: Sendable>(_ type: T.Type) async -> T? where T.Type: Sendable {
        await ioc.getAsync(by: type)
    }

    static func optionalResolve<T>(_ type: T.Type) -> T? {
        ioc.get(by: type)
    }

    static func resolveAsync<T: Sendable>(_ type: T.Type) async -> T {
        await ioc.getAsync(by: type)!
    }

    static func resolve<T>(_ type: T.Type) -> T {
        ioc.get(by: type)!
    }
}
