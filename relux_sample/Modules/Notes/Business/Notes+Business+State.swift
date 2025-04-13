import Combine

extension Notes.Business {
    actor State {
        @Published var notes: MaybeData<[Model.Note], Err> = .initial()
    }
}

extension Notes.Business.State: Relux.BusinessState  {
    func reduce(with action: any Relux.Action) async {
        switch action as? Notes.Business.Action {
            case .none: break
            case let .some(action): await internalReduce(with: action)
        }
    }
    
    func cleanup() async {
        self.notes = .initial()
    }
}
