extension Auth.Business.State {
    func internalReduce(with action: Auth.Business.Action) {
        switch action {
            case .authSucceed: break
            case .authFailed:  break
            case .logOutSucceed: break

            case .obtainAvailableBiometryTypeSucceed(type: let type):
                self.availableBiometryType = type
        }
    }
}
