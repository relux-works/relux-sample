import Auth
import Relux

extension Auth.Business {
    public actor Saga {
        private let svc: IService
        private let router: IRouter

        public init(
            svc: IService,
            router: IRouter
        ) {
            self.svc = svc
            self.router = router
        }
    }
}

extension Auth.Business.Saga: Auth.Business.ISaga {
    public func apply(_ effect: any Relux.Effect) async {
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
        await actions {
            router.setAuth(page: .localAuth)
        }
    }

    private func obtainAvailableBiometryType() async {
        let type = await svc.availableBiometry
        await actions {
            Auth.Business.Action.obtainAvailableBiometryTypeSucceed(type: type)
        }
    }

    private func authorizeWithBiometry() async {
        switch await svc.runLocalAuth() {
            case .success:
                await actions {
                    Auth.Business.Action.authSucceed
                    router.pushMain()
                }
            case let .failure(err):
                await actions {
                    Auth.Business.Action.authFailed(err: err)
                }
        }
    }

    private func logout() async {
        await actions {
            router.setAuth(page: .logoutFlow)
        }
    }

    private func runLogoutFlow() async {
        await svc.recreateLAContext()
        await actions {
            router.setAuth(page: .localAuth)
            Auth.Business.Action.logOutSucceed
        }
    }
}
