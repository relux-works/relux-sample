extension Auth.Business {
    enum Action: Relux.Action {
        case authSucceed
        case authFailed(err: Err)
        case obtainAvailableBiometryTypeSucceed(type: Model.BiometryType)

        case logOutSucceed
    }
}
