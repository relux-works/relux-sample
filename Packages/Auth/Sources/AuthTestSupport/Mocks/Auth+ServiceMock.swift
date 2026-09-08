import AuthModels
import AuthServiceInt

extension Auth.Business {
    public final class ServiceMock: IService, @unchecked Sendable {
        public var availableBiometryHandler: (() -> Model.BiometryType)?
        public var runLocalAuthHandler: (() -> Result<Bool, Err>)?

        public private(set) var runLocalAuthCallCount = 0

        public init() {}


        public var availableBiometry: Model.BiometryType {
            get async { availableBiometryHandler?() ?? .face(allowed: true) }
        }

        public func runLocalAuth() async -> Result<Bool, Err> {
            runLocalAuthCallCount += 1
            return runLocalAuthHandler?() ?? .success(true)
        }

        public func recreateLAContext() async {}
    }
}
