import SwiftIoC

extension SampleApp {
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
            Navigation.Module()
            SampleApp.Module()
            Auth.Module()
        }
    }

    private static func buildReluxStore() -> Relux.Store {
        Relux.Store()
    }

    private static func buildReluxRootSaga() -> Relux.RootSaga {
        Relux.RootSaga()
    }

    private static func buildReluxLogger() -> Relux.Logger {
        ReluxLogger()
    }
}

// resolvers
extension SampleApp.Registry {
    static func optionalResolveAsync<T: Sendable>(_ type: T.Type) async -> T? where T.Type: Sendable {
        await ioc.get(by: type)
    }

    static func optionalResolve<T>(_ type: T.Type) -> T? {
        ioc.get(by: type)
    }

    static func resolveAsync<T: Sendable>(_ type: T.Type) async -> T {
        await ioc.get(by: type)!
    }

    static func resolve<T>(_ type: T.Type) -> T {
        ioc.get(by: type)!
    }
}
