import LocalAuthentication

extension Auth.Business {
    protocol IService {
        typealias Err = Auth.Business.Err
        typealias Model = Auth.Business.Model

        var laContext: LAContext { get }
        var availableBiometry: Model.BiometryType { get }
        func runLocalAuth() async -> Result<Bool, Err>
        func recreateLAContext()
    }
}

extension Auth.Business {
    final class Service {
        private var laCtx: LAContext

        init() {
            laCtx = Self.createContext()
        }
    }
}

extension Auth.Business.Service: Auth.Business.IService {
    var laContext: LAContext { laCtx }

    var availableBiometry: Model.BiometryType {
        var error: NSError?
        let allowed = laContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)

        return switch laContext.biometryType {
            case .none: .other(allowed: allowed)
            case .touchID: .touch(allowed: allowed)
            case .faceID: .face(allowed: allowed)
            case .opticID: .other(allowed: allowed)
            @unknown default: .other(allowed: allowed)
        }
    }

    func runLocalAuth() async -> Result<Bool, Auth.Business.Err> {
        await withCheckedContinuation { ctx in
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

    func recreateLAContext() {
        laCtx.invalidate()
        laCtx = Self.createContext()
    }

    private static func createContext() -> LAContext {
        let ctx = LAContext()
        return ctx
    }
}
