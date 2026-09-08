import Testing
import AuthModels
import AuthReluxInt
import AuthReluxImpl
import AuthServiceInt
import Relux

@Suite(.serialized)
@MainActor
struct AuthBehaviorTests {
    @Test(arguments: [true, false])
    func biometryReflectsAvailability(allowed: Bool) {
        #expect(Auth.Business.Model.BiometryType.face(allowed: allowed).allowed == allowed)
        #expect(Auth.Business.Model.BiometryType.touch(allowed: allowed).allowed == allowed)
        #expect(Auth.Business.Model.BiometryType.other(allowed: allowed).allowed == allowed)
    }

    @Test
    func authorizationTrueRoutesToMain() async {
        let logger = await authorize(.success(true))
        #expect(logger.actions.contains { ($0 as? Route) == .main })
        #expect(logger.actions.contains { if case .authSucceed = $0 as? Auth.Business.Action { true } else { false } })
    }

    @Test
    func authorizationFalseNeverRoutesToMain() async {
        let logger = await authorize(.success(false))
        #expect(!logger.actions.contains { ($0 as? Route) == .main })
        #expect(!logger.actions.contains { if case .authSucceed = $0 as? Auth.Business.Action { true } else { false } })
        #expect(logger.actions.contains { if case .authFailed = $0 as? Auth.Business.Action { true } else { false } })
    }

    @Test
    func authorizationFailureNeverRoutesToMain() async {
        let logger = await authorize(.failure(.failedToAuthWithBiometry_localAuthWithBiometryIsNotSupported))
        #expect(!logger.actions.contains { ($0 as? Route) == .main })
        #expect(logger.actions.contains { if case .authFailed = $0 as? Auth.Business.Action { true } else { false } })
    }

    @Test
    func registeredModuleReducesBiometryAndCleansUp() async throws {
        let service = Service(result: .success(true))
        let module = Auth.Module(router: Router(), serviceFactory: { service })
        let relux = await Relux(logger: Relux.Testing.Logger())
        defer { Relux.shared = nil }
        relux.register(module)
        await relux.dispatcher.actions { Auth.Business.Effect.obtainAvailableBiometryType }
        let state = try #require(module.states.first as? Auth.Business.State)
        #expect(state.availableBiometryType == .face(allowed: false))
        await relux.unregister(module)
        #expect(state.availableBiometryType == nil)
    }

    @Test
    func logoutRecreatesContextBeforeRoutingToLocalAuth() async {
        let service = Service(result: .success(true))
        let logger = Relux.Testing.Logger()
        let relux = await Relux(logger: logger)
        defer { Relux.shared = nil }
        relux.register(Auth.Module(router: Router(), serviceFactory: { service }))
        await relux.dispatcher.actions { Auth.Business.Effect.runLogoutFlow }
        #expect(await service.resetCount == 1)
        #expect(logger.actions.contains { ($0 as? Route) == .localAuth })
        #expect(logger.actions.contains { if case .logOutSucceed = $0 as? Auth.Business.Action { true } else { false } })
    }

    @Test
    func authContextAndLogoutChooseTheirRoutes() async {
        let service = Service(result: .success(true))
        let logger = Relux.Testing.Logger()
        let relux = await Relux(logger: logger)
        defer { Relux.shared = nil }
        relux.register(Auth.Module(router: Router(), serviceFactory: { service }))
        await relux.dispatcher.actions { Auth.Business.Effect.checkAuthContext }
        #expect(logger.actions.contains { ($0 as? Route) == .localAuth })
        await relux.dispatcher.actions { Auth.Business.Effect.logout }
        #expect(logger.actions.contains { ($0 as? Route) == .logout })
        #expect(await service.authCount == 0)
    }

    private func authorize(_ result: Result<Bool, Auth.Business.Err>) async -> Relux.Testing.Logger {
        let service = Service(result: result)
        let logger = Relux.Testing.Logger()
        let relux = await Relux(logger: logger)
        defer { Relux.shared = nil }
        relux.register(Auth.Module(router: Router(), serviceFactory: { service }))
        await relux.dispatcher.actions { Auth.Business.Effect.authorizeWithBiometry }
        #expect(await service.authCount == 1)
        return logger
    }
}

private enum Route: Relux.Action, Equatable {
    case main, localAuth, logout
}

private struct Router: Auth.Business.IRouter {
    func pushMain() -> any Relux.Action { Route.main }
    func setAuth(page: Auth.UI.Model.Page) -> any Relux.Action {
        switch page {
        case .localAuth: Route.localAuth
        case .logoutFlow: Route.logout
        }
    }
}

private actor Service: Auth.Business.IService {
    let result: Result<Bool, Auth.Business.Err>
    var authCount = 0
    var resetCount = 0
    init(result: Result<Bool, Auth.Business.Err>) { self.result = result }
    var availableBiometry: Auth.Business.Model.BiometryType { .face(allowed: false) }
    func runLocalAuth() -> Result<Bool, Auth.Business.Err> {
        authCount += 1
        return result
    }
    func recreateLAContext() { resetCount += 1 }
}
