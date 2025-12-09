extension Notes.UI {
    final class State: ObservableObject, Relux.UIState {
        typealias Note = Notes.Business.Model.Note
        typealias Err = Notes.Business.Err

        @Published var notesGroupedByDay: MaybeData<[[Note]], Err> = .initial()
        @Published var notes: MaybeData<[Note.Id: Note], Err> = .initial()

        init(
            state: Notes.Business.State
        ) async {
            await initPipelines(state: state)
        }
    }
}

extension Notes.UI.State {
    func note(by id: Note.Id) -> MaybeData<Note?, Err> {
        switch notes {
            case .initial: .initial()
            case let .failure(err): .failure(err)
            case let .success(notes): .success(notes[id])
        }
    }
}

extension Notes.UI.State {
    private func initPipelines(state: Notes.Business.State) async {
        await state.$notes
            .map(Self.mapNotesToGroups)
            .receive(on: mainQueue)
            .assign(to: &$notesGroupedByDay)

        await state.$notes
            .map(Self.mapNotesToDict)
            .receive(on: mainQueue)
            .assign(to: &$notes)
    }

    nonisolated
    private static func mapNotesToDict(_ notes: MaybeData<[Note], Err>) -> MaybeData<[Note.Id: Note], Err> {
        switch notes {
            case .initial: .initial()
            case let .failure(err): .failure(err)
            case let .success(notes): .success(notes.keyed(by: \.id))
        }
    }

    nonisolated
    private static func mapNotesToGroups(_ notes: MaybeData<[Note], Err>) -> MaybeData<[[Note]], Err> {
        switch notes {
            case .initial: return .initial()
            case let .failure(err): return .failure(err)
            case let .success(notes): return .success(
                notes
                    .sorted { $0.createdAt > $1.createdAt }
                    .chunked { prev, next in
                        prev.createdAt.startOfDay == next.createdAt.startOfDay
                    }
                    .map { $0.asArray }
            )
        }
    }
}

