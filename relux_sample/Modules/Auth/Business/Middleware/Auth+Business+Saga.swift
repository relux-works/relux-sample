extension Auth.Business {
    protocol ISaga: Relux.Saga {}
}

extension Auth.Business {
    actor Saga {
        private let svc: IService

        init(
            svc: IService
        ) {
            self.svc = svc
        }
    }
}

extension Auth.Business.Saga: Auth.Business.ISaga {
    func apply(_ effect: any Relux.Effect) async {
        switch effect as? Auth.Business.Effect {
            case .none: break
            case .checkAuthContext: await checkAuthContext()
            case .obtainAvailableBiometryType: await obtainAvailableBiometryType()
            case .authorizeWithBiometry: await authorizeWithBiometry()
            case .logout: await logout()
            case .runLogoutFlow: await runLogoutFlow()
        }
    }
}

extension Auth.Business.Saga {
    private func checkAuthContext() async {
        await action {
            AppRouter.Action.set([.auth(page: .localAuth)])
        }
    }

    private func obtainAvailableBiometryType() async {
        let type = svc.availableBiometry
        await action {
            Auth.Business.Action.obtainAvailableBiometryTypeSucceed(type: type)
        }
    }

    private func authorizeWithBiometry() async {
        switch await svc.runLocalAuth() {
            case .success:
                await actions {
                    Auth.Business.Action.authSucceed
                    AppRouter.Action.push(.app(page: .main))
                }
            case let .failure(err):
                await action {
                    Auth.Business.Action.authFailed(err: err)
                }
        }
    }

    private func logout() async {
        await actions {
            AppRouter.Action.set([.auth(page: .logoutFlow)])
        }
    }

    private func runLogoutFlow() async {
        svc.recreateLAContext()
        await actions {
            AppRouter.Action.set([.auth(page: .localAuth)])
            Auth.Business.Action.logOutSucceed
        }
    }
}
