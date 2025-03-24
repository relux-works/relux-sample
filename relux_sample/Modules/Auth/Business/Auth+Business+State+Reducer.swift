extension Auth.Business.State {
    func internalReduce(with action: Auth.Business.Action) {
        switch action {
            case .authSucceed:
                self.loggedIn = true

            case .authFailed:
                break

            case .logOutSucceed:
                self.loggedIn = false

            case .obtainAvailableBiometryTypeSucceed(type: let type):
                self.availableBiometryType = type
        }
    }
}
