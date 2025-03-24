extension SampleApp {
    @MainActor
    struct Module: Relux.Module {
        let states: [any Relux.AnyState] = []
        let sagas: [any Relux.Saga]

        init() {
            let saga: SampleApp.Business.ISaga = SampleApp.Business.Saga()
            self.sagas = [saga]
        }
    }
}
