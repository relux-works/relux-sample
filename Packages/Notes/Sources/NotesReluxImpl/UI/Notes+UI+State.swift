@preconcurrency import Combine
import Foundation
import NotesModels
import NotesReluxInt
import Relux
import SwiftUIRelux

extension Notes.UI {
    public final class State: ObservableObject, Relux.UIState {
        public typealias Note = Notes.Business.Model.Note
        public typealias Err = Notes.Business.Err

        @Published public var notesGroupedByDay: MaybeData<[[Note]], Err> = .initial()
        @Published public var notes: MaybeData<[Note.Id: Note], Err> = .initial()

        public init(
            state: Notes.Business.State
        ) async {
            await initPipelines(state: state)
        }
    }
}

extension Notes.UI.State {
    public func note(by id: Note.Id) -> MaybeData<Note?, Err> {
        switch notes {
            case .initial: .initial()
            case let .failure(err): .failure(err)
            case let .success(notes): .success(notes[id])
        }
    }
}

private extension Notes.UI.State {
    func initPipelines(state: Notes.Business.State) async {
        await state.$notes
            .map(Self.mapNotesToGroups)
            .receive(on: DispatchQueue.main)
            .assign(to: &$notesGroupedByDay)

        await state.$notes
            .map(Self.mapNotesToDict)
            .receive(on: DispatchQueue.main)
            .assign(to: &$notes)
    }

    nonisolated static func mapNotesToDict(_ notes: MaybeData<[Note], Err>) -> MaybeData<[Note.Id: Note], Err> {
        switch notes {
            case .initial: .initial()
            case let .failure(err): .failure(err)
            case let .success(notes): .success(notes.keyed(by: \.id))
        }
    }

    nonisolated static func mapNotesToGroups(_ notes: MaybeData<[Note], Err>) -> MaybeData<[[Note]], Err> {
        switch notes {
            case .initial: return .initial()
            case let .failure(err): return .failure(err)
            case let .success(notes): return .success(
                notes
                    .sorted { $0.createdAt > $1.createdAt }
                    .chunked { prev, next in
                        prev.createdAt.startOfDay == next.createdAt.startOfDay
                    }
                    .map { Array($0) }
            )
        }
    }
}
