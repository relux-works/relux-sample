extension Auth.Business {
    enum Effect: Relux.Effect {
        case checkAuthContext
        case obtainAvailableBiometryType
        case authorizeWithBiometry
        case logout
        case runLogoutFlow
    }
}
