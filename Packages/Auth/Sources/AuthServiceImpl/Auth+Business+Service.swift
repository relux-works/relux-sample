import LocalAuthentication
import AuthModels
import AuthServiceInt

extension Auth.Business {
    public actor Service: IService {
        private let contextFactory: @Sendable () -> LAContext

        public init() { self.contextFactory = { LAContext() } }

        // Internal seam for deterministic policy tests; public construction always uses the system context.
        init(contextFactory: @escaping @Sendable () -> LAContext) {
            self.contextFactory = contextFactory
        }

        public func runLocalAuth() async -> Result<Bool, Err> {
            guard !Task.isCancelled else { return .failure(.cancelled) }
            // Each request owns a fresh context; no previous note's credential reuse.
            let context = contextFactory()
            defer { context.invalidate() }
            var error: NSError?
            guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else {
                return .failure(.unavailable)
            }
            do {
                let authorized = try await context.evaluatePolicy(
                    .deviceOwnerAuthentication, localizedReason: "Unlock this note."
                )
                guard !Task.isCancelled else { return .failure(.cancelled) }
                return .success(authorized)
            } catch let error as LAError {
                switch error.code {
                case .userCancel, .appCancel, .systemCancel: return .failure(.cancelled)
                default: return .failure(.evaluationFailed)
                }
            } catch {
                return .failure(.evaluationFailed)
            }
        }
    }
}
