extension Auth.Business {
    public enum Err: Error {
        case authenticationRejected
        case failedToAuthWithBiometry_localAuthWithBiometryIsNotSupported
        case failedToAuthWithBiometry(cause: Error)
    }
}
