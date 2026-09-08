import AuthModels

extension Auth.Business {
    public protocol IService: Sendable {
        func runLocalAuth() async -> Result<Bool, Err>
    }
}
