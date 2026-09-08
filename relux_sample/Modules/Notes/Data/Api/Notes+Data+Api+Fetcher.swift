extension Notes.Data.Api {
    struct Snapshot: Sendable {
        let revision: UInt64
        let notes: [DTO.Note]
    }

    protocol IFetcher: Sendable {
        typealias Err = Notes.Business.Err
        typealias DTO = Notes.Data.Api.DTO
        func snapshot() async -> Snapshot
        func upsert(note: DTO.Note) async -> Result<Void, Err>
        func deletetNote(by id: DTO.Note.Id) async -> Result<Void, Err>
        func setProtection(noteId: DTO.Note.Id, protected: Bool) async -> Result<Void, Err>
        func unlock(noteId: DTO.Note.Id) async -> Result<Void, Err>
        func relock(noteId: DTO.Note.Id?) async
    }

    actor Fetcher {
        private let authenticate: @Sendable () async -> Bool
        private var grants: Set<DTO.Note.Id> = []
        private var generations: [DTO.Note.Id: UInt64] = [:]
        private var revision: UInt64 = 0

        init(authenticate: @escaping @Sendable () async -> Bool = { false }) {
            self.authenticate = authenticate
        }
        private var notes: Dictionary<DTO.Note.Id, DTO.Note> = [
            .init(id: .init(), date: .now, title: "Welcome to Notes",
                  content: "Capture an idea, edit it, then try searching for a word in its title or body. Changes stay in memory and reset when the app restarts."),
            .init(id: .init(), date: .now.add(days: -1), title: "Weekend checklist",
                  content: "Pick up coffee beans\nTake a walk by the river\nBring a notebook"),
            .init(id: .init(), date: .now.add(days: -2), title: "How this demo works",
                  content: "A container dispatches an effect. The Notes flow calls a service, then dispatches an action. The reducer updates business state and the UI projection refreshes the screen.")
        ].keyed(by: \.id)
    }
}

extension Notes.Data.Api.Fetcher: Notes.Data.Api.IFetcher {
    func snapshot() -> Notes.Data.Api.Snapshot {
        revision += 1
        let projected = notes.values.map { note in
            let locked = note.isProtected && !grants.contains(note.id)
            return DTO.Note(id: note.id, date: note.date, title: note.title,
                            content: locked ? "" : note.content,
                            isProtected: note.isProtected, isLocked: locked)
        }
        return .init(revision: revision, notes: projected)
    }

    func upsert(note: DTO.Note) -> Result<Void, Err> {
        guard canAccess(note.id) else { return .failure(.locked) }
        // Existing provider metadata wins over stale or forged editor metadata.
        notes[note.id] = DTO.Note(id: note.id, date: note.date, title: note.title, content: note.content,
                                  isProtected: notes[note.id]?.isProtected ?? false)
        return .success(())
    }

    func deletetNote(by id: DTO.Note.Id) -> Result<Void, Err> {
        guard canAccess(id) else { return .failure(.locked) }
        revoke(id)
        notes.removeValue(forKey: id)
        return .success(())
    }

    func setProtection(noteId: DTO.Note.Id, protected: Bool) -> Result<Void, Err> {
        guard var note = notes[noteId] else { return .failure(.notFound) }
        guard canAccess(noteId) else { return .failure(.locked) }
        note.isProtected = protected
        notes[noteId] = note
        revoke(noteId)
        return .success(())
    }

    func unlock(noteId: DTO.Note.Id) async -> Result<Void, Err> {
        guard let note = notes[noteId] else { return .failure(.notFound) }
        guard note.isProtected else { return .success(()) }
        revoke(noteId)
        let generation = generations[noteId, default: 0]
        let authorized = await authenticate()
        guard authorized, !Task.isCancelled,
              generations[noteId, default: 0] == generation,
              notes[noteId]?.isProtected == true else { return .failure(.authenticationDenied) }
        grants.insert(noteId)
        return .success(())
    }

    func relock(noteId: DTO.Note.Id?) {
        if let noteId { revoke(noteId) }
        else { for id in notes.keys { revoke(id) } }
    }

    private func canAccess(_ id: DTO.Note.Id) -> Bool {
        notes[id]?.isProtected != true || grants.contains(id)
    }

    private func revoke(_ id: DTO.Note.Id) {
        generations[id, default: 0] += 1
        grants.remove(id)
    }
}
