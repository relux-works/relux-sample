import AuthModels
import AuthReluxInt
import AuthServiceInt
import Relux

extension Auth {
    public struct Module: Relux.Module {
        public let states: [any Relux.AnyState] = []
        public let sagas: [any Relux.Saga]
        public let flow: any Business.IFlow

        public init(service: any Business.IService) {
            let flow = Business.Flow(svc: service)
            self.flow = flow
            self.sagas = [flow]
        }
    }
}
