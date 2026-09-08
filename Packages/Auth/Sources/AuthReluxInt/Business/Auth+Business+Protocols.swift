import AuthModels
import Relux

extension Auth.Business {
    public protocol IFlow: Relux.Flow {
        func authenticate() async -> Swift.Result<Void, Err>
    }
}
