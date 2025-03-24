extension Auth {
    @MainActor
    struct Module: Relux.Module {
        let states: [any Relux.AnyState]
        let sagas: [any Relux.Saga]

        init() {
            let state = Auth.Business.State()
            let svc: Auth.Business.IService = Auth.Business.Service()
            let saga: Auth.Business.ISaga = Auth.Business.Saga(svc: svc)

            self.states = [
                state
            ]
            self.sagas = [
                saga
            ]
        }
    }
}
