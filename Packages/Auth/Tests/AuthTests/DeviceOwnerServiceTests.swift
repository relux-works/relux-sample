import Foundation
import LocalAuthentication
import Testing
import AuthModels
@testable import AuthServiceImpl

@Suite struct DeviceOwnerServiceTests {
    @Test(arguments: [LAError.Code.passcodeNotSet, .biometryNotAvailable])
    func unavailablePolicyNeverEvaluatesOrAuthorizes(code: LAError.Code) async {
        let context = ScriptedContext(available: false, success: true, errorCode: code)
        let service = Auth.Business.Service(contextFactory: { context })
        guard case .failure = await service.runLocalAuth() else { Issue.record("Unavailable must fail"); return }
        #expect(context.evaluationCount == 0)
        #expect(context.policies == [.deviceOwnerAuthentication])
        #expect(context.invalidationCount == 1)
    }

    @Test(arguments: [true, false])
    func deviceOwnerPolicyReturnsActualBoolean(success: Bool) async {
        let context = ScriptedContext(available: true, success: success)
        let service = Auth.Business.Service(contextFactory: { context })
        #expect((try? await service.runLocalAuth().get()) == success)
        #expect(context.policies == [.deviceOwnerAuthentication, .deviceOwnerAuthentication])
        #expect(context.invalidationCount == 1)
    }

    @Test(arguments: [LAError.Code.userCancel, .appCancel, .systemCancel, .authenticationFailed])
    func evaluationErrorsNeverAuthorize(code: LAError.Code) async {
        let context = ScriptedContext(available: true, success: false, errorCode: code)
        let service = Auth.Business.Service(contextFactory: { context })
        guard case .failure = await service.runLocalAuth() else { Issue.record("Error must fail"); return }
        #expect(context.invalidationCount == 1)
    }

    @Test func everyRequestCreatesAndInvalidatesItsOwnContext() async {
        let factory = ContextFactory()
        let service = Auth.Business.Service(contextFactory: { factory.make() })
        _ = await service.runLocalAuth()
        _ = await service.runLocalAuth()
        let contexts = factory.contexts
        #expect(contexts.count == 2)
        #expect(contexts[0] !== contexts[1])
        #expect(contexts.allSatisfy { $0.evaluationCount == 1 && $0.invalidationCount == 1 })
    }
}

private final class ContextFactory: @unchecked Sendable {
    private let lock = NSLock()
    private var storage: [ScriptedContext] = []
    var contexts: [ScriptedContext] { lock.withLock { storage } }
    func make() -> LAContext {
        lock.withLock {
            let context = ScriptedContext(available: true, success: true)
            storage.append(context)
            return context
        }
    }
}

private final class ScriptedContext: LAContext, @unchecked Sendable {
    private let lock = NSLock()
    private let available: Bool
    private let success: Bool
    private let errorCode: LAError.Code?
    private var evaluated = 0
    private var invalidated = 0
    private var requestedPolicies: [LAPolicy] = []
    var evaluationCount: Int { lock.withLock { evaluated } }
    var invalidationCount: Int { lock.withLock { invalidated } }
    var policies: [LAPolicy] { lock.withLock { requestedPolicies } }

    init(available: Bool, success: Bool, errorCode: LAError.Code? = nil) {
        self.available = available
        self.success = success
        self.errorCode = errorCode
        super.init()
    }

    override func canEvaluatePolicy(_ policy: LAPolicy, error: NSErrorPointer) -> Bool {
        lock.withLock { requestedPolicies.append(policy) }
        if !available, let errorCode { error?.pointee = LAError(errorCode) as NSError }
        return available
    }

    override func evaluatePolicy(_ policy: LAPolicy, localizedReason: String,
                                 reply: @escaping @Sendable (Bool, (any Error)?) -> Void) {
        lock.withLock { evaluated += 1; requestedPolicies.append(policy) }
        // Unavailable fixtures would succeed if the production preflight were bypassed.
        reply(success, available ? errorCode.map { LAError($0) } : nil)
    }

    override func invalidate() { lock.withLock { invalidated += 1 } }
}
