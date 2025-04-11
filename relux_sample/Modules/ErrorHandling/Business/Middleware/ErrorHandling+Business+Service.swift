extension ErrorHandling.Business {
    protocol IService: Sendable {
        func track(error: Error) async
    }
}

extension ErrorHandling.Business {
    actor Service {
        init() {
        }
    }
}

extension ErrorHandling.Business.Service: ErrorHandling.Business.IService {
    func track(error: any Error) async {
        print(">>> crashlytics track \(error)")
    }
}
