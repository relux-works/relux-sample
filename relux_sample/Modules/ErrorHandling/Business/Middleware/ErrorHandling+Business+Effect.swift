extension ErrorHandling.Business {
    enum Effect: Relux.Effect {
        case track(error: Error)
    }
}
