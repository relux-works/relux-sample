import Relux

extension Auth.Business {
    public enum Effect: Relux.Effect {
        case checkAuthContext
        case obtainAvailableBiometryType
        case authorizeWithBiometry
        case logout
        case runLogoutFlow
    }
}
