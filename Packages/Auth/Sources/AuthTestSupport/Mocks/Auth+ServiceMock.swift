import AuthModels
import AuthServiceInt

extension Auth.Business {
    public actor ServiceMock: IService {
        public var result: Result<Bool, Err>
        public private(set) var callCount = 0
        public init(result: Result<Bool, Err> = .failure(.unavailable)) { self.result = result }
        public func runLocalAuth() -> Result<Bool, Err> {
            callCount += 1
            return result
        }
    }
}
