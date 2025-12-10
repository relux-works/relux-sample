import Combine
import NotesModels
import NotesReluxInt
import Relux

extension Notes.Business {
    public actor State: Notes.Business.IState {
        public typealias Model = Notes.Business.Model

        @Published public var notes: MaybeData<[Model.Note], Err> = .initial()

        public init() {}

        public func reduce(with action: any Relux.Action) async {
            switch action as? Notes.Business.Action {
                case .none: break
                case let .some(action): await internalReduce(with: action)
            }
        }

        public func cleanup() async {
            notes = .initial()
        }
    }
}
