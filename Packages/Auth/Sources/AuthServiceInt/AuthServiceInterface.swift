import AuthModels

extension Auth.Business {
    public protocol IService: Sendable {
        typealias Err = Auth.Business.Err
        typealias Model = Auth.Business.Model

        var availableBiometry: Model.BiometryType { get async }
        func runLocalAuth() async -> Result<Bool, Err>
        func recreateLAContext() async
    }
}
