import AuthModels
import LocalAuthentication

extension Auth.Business {
    public protocol IService: Sendable {
        typealias Err = Auth.Business.Err
        typealias Model = Auth.Business.Model

        var laContext: LAContext { get async }
        var availableBiometry: Model.BiometryType { get async }
        func runLocalAuth() async -> Result<Bool, Err>
        func recreateLAContext() async
    }
}
