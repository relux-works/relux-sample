import AuthModels
import Relux

extension Auth.Business {
    public enum Action: Relux.Action {
        case authSucceed
        case authFailed(err: Err)
        case obtainAvailableBiometryTypeSucceed(type: Model.BiometryType)

        case logOutSucceed
    }
}
