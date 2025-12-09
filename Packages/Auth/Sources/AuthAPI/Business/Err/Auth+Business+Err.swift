extension Auth.Business {
    public enum Err: Error {
        case failedToAuthWithBiometry_localAuthWithBiometryIsNotSupported
        case failedToAuthWithBiometry(cause: Error)
    }
}
