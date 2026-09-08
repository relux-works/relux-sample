import AuthModels
import AuthReluxInt
import AuthServiceInt
import Relux

extension Auth.Business {
    public actor Flow: IFlow {
        private let svc: any IService
        public init(svc: any IService) { self.svc = svc }

        public func authenticate() async -> Swift.Result<Void, Err> {
            guard !Task.isCancelled else { return .failure(.cancelled) }
            let result = await svc.runLocalAuth()
            guard !Task.isCancelled else { return .failure(.cancelled) }
            switch result {
            case .success(true): return .success(())
            case .success(false): return .failure(.authenticationRejected)
            case .failure(let error): return .failure(error)
            }
        }

        public func apply(_ effect: any Relux.Effect) async -> Relux.Flow.Result {
            guard effect is Auth.Business.Effect else { return .success }
            switch await authenticate() {
            case .success: return .success
            case .failure(let error): return .failure(error)
            }
        }
    }
}
