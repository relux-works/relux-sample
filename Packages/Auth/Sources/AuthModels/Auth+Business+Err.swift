extension Auth.Business {
    public enum Err: Error, Sendable {
        case authenticationRejected
        case unavailable
        case cancelled
        case evaluationFailed
    }
}
