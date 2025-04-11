extension Notes.UI {
    final class State: ObservableObject, Relux.UIState {
        typealias Note = Notes.Business.Model.Note
        typealias Err = Notes.Business.Err

        @Published var notesGroupedByDay: MaybeData<[[Note]], Err> = .initial()

        init(
            state: Notes.Business.State
        ) async {
            await initPipelines(state: state)
        }
    }
}

extension Notes.UI.State {
    private func initPipelines(state: Notes.Business.State) async {
        await state.$notes
            .map(Self.mapNotesToGroups)
            .receive(on: mainQueue)
            .assign(to: &$notesGroupedByDay)
    }

    nonisolated
    private static func mapNotesToGroups(_ notes: MaybeData<[Note], Err>) -> MaybeData<[[Note]], Err> {
        switch notes {
            case .initial: return .initial()
            case let .failure(err): return .failure(err)
            case let .success(notes): return .success(
                notes
                    .chunked { prev, next in
                        prev.createdAt.startOfDay == next.createdAt.startOfDay
                    }
                    .map { $0.asArray }
            )
        }
    }
}
