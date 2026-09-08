import Testing
import AuthModels
import AuthReluxInt
import AuthReluxImpl
import AuthServiceInt
import Relux

@Suite struct AuthBehaviorTests {
    @Test func authorizationTrueReturnsSuccess() async {
        let flow = Auth.Business.Flow(svc: Service(result: .success(true)))
        let result = await flow.authenticate()
        guard case .success = result else { Issue.record("Expected authorization"); return }
    }

    @Test func authorizationFalseReturnsFailure() async {
        let flow = Auth.Business.Flow(svc: Service(result: .success(false)))
        guard case .failure = await flow.authenticate() else { Issue.record("False must fail"); return }
    }

    @Test func unavailableAuthenticationReturnsFailure() async {
        let flow = Auth.Business.Flow(svc: Service(result: .failure(.unavailable)))
        guard case .failure = await flow.authenticate() else { Issue.record("Unavailable must fail"); return }
    }

    @Test func cancelledAuthenticationReturnsFailure() async {
        let flow = Auth.Business.Flow(svc: Service(result: .failure(.cancelled)))
        guard case .failure = await flow.authenticate() else { Issue.record("Cancellation must fail"); return }
    }

    @Test func taskCancelledDuringAuthenticationCannotSucceed() async {
        let service = SuspendedService()
        let flow = Auth.Business.Flow(svc: service)
        let pending = Task { await flow.authenticate() }
        await service.waitUntilStarted()
        pending.cancel()
        await service.resolve()
        guard case .failure = await pending.value else { Issue.record("Cancelled task must fail"); return }
    }

    @Test func alreadyCancelledTaskDoesNotStartAuthentication() async {
        let service = Service(result: .success(true))
        let flow = Auth.Business.Flow(svc: service)
        let pending = Task {
            withUnsafeCurrentTask { $0?.cancel() }
            return await flow.authenticate()
        }
        guard case .failure = await pending.value else { Issue.record("Cancelled task must fail"); return }
        #expect(await service.calls == 0)
    }

    @Test func failedAuthenticationReturnsFailure() async {
        let flow = Auth.Business.Flow(svc: Service(result: .failure(.authenticationRejected)))
        guard case .failure = await flow.apply(Auth.Business.Effect.authenticate) else {
            Issue.record("Failure through Relux entry must fail"); return
        }
    }
}

private actor Service: Auth.Business.IService {
    let result: Result<Bool, Auth.Business.Err>
    init(result: Result<Bool, Auth.Business.Err>) { self.result = result }
    var calls = 0
    func runLocalAuth() -> Result<Bool, Auth.Business.Err> { calls += 1; return result }
}

private actor SuspendedService: Auth.Business.IService {
    private var continuation: CheckedContinuation<Result<Bool, Auth.Business.Err>, Never>?
    private var started: CheckedContinuation<Void, Never>?
    func runLocalAuth() async -> Result<Bool, Auth.Business.Err> {
        await withCheckedContinuation { continuation in
            self.continuation = continuation
            started?.resume()
            started = nil
        }
    }
    func waitUntilStarted() async {
        if continuation != nil { return }
        await withCheckedContinuation { started = $0 }
    }
    func resolve() { continuation?.resume(returning: .success(true)); continuation = nil }
}
