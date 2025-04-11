extension ErrorHandling.Business {
    protocol ISaga: Relux.Saga {}
}

extension ErrorHandling.Business {
    actor Saga {
        private let svc: IService

        init(
            svc: IService
        ) {
            self.svc = svc
        }
    }
}

extension ErrorHandling.Business.Saga: ErrorHandling.Business.ISaga {
    func apply(_ effect: any Relux.Effect) async {
        switch effect as? ErrorHandling.Business.Effect {
            case .none: break
            case let .track(error): await tack(error)
        }
    }
}

extension ErrorHandling.Business.Saga {
    private func tack(_ error: Error) async {
        await svc.track(error: error)
    }
}
