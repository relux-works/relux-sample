extension Auth.Business {
    enum Err: Error {
        case failedToAuthWithBiometry_localAuthWithBiometryIsNotSupported
        case failedToAuthWithBiometry(cause: Error)
    }
}
