import LocalAuthentication
import AuthModels
import AuthServiceInt

extension Auth.Business {
    public actor Service {
        public typealias Model = Auth.Business.Model
        private var laCtx: LAContext

        public init() {
            laCtx = Self.createContext()
        }
    }
}

extension Auth.Business.Service: Auth.Business.IService {
    // LAContext remains owned by this actor; interfaces expose domain values only.

    public var availableBiometry: Model.BiometryType { get async {

        var error: NSError?
        let allowed = laCtx.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)

        return switch laCtx.biometryType {
            case .none: .other(allowed: allowed)
            case .touchID: .touch(allowed: allowed)
            case .faceID: .face(allowed: allowed)
            case .opticID: .other(allowed: allowed)
            @unknown default: .other(allowed: allowed)
        }
    }}

    public func runLocalAuth() async -> Result<Bool, Auth.Business.Err> {
        let laContext = self.laCtx
        return await withCheckedContinuation { ctx in
            var error: NSError?
            if laContext.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
                let reason = "We need to unlock your data."

                laContext.evaluatePolicy(
                    .deviceOwnerAuthentication, localizedReason: reason
                ) { success, authenticationError in
                    switch authenticationError {
                        case .none:
                            ctx.resume(returning: .success(success))
                        case let .some(err):
                            ctx.resume(returning: .failure(.failedToAuthWithBiometry(cause: err)))
                    }
                }
            } else {
                ctx.resume(returning: .failure(.failedToAuthWithBiometry_localAuthWithBiometryIsNotSupported))
            }
        }
    }

    public func recreateLAContext() {
        laCtx.invalidate()
        laCtx = Self.createContext()
    }

    private static func createContext() -> LAContext {
        let ctx = LAContext()
        return ctx
    }
}
