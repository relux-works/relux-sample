extension Notes.Business.State {
    func internalReduce(with action: Notes.Business.Action) async {
        switch action {
            case let .obtainNotesSuccess(notes):
                self.notes = .success(notes)
            case let .obtainNotesFail(err):
                self.notes = .failure(err)

            case let .upsertNoteSuccess(note):
                var notes = (self.notes.value ?? [])
                notes.upsertByIdentity(note)
                self.notes = .success(notes)
            case .upsertNoteFail:
                break

            case let .deleteNoteSuccess(note):
                var notes = (self.notes.value ?? [])
                notes.removeById(note)
                self.notes = .success(notes)

            case .deleteNoteFail:
                break
        }
    }
}
