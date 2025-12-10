import NotesModels
import NotesReluxInt
import Relux

extension Notes.Business.State {
    func internalReduce(with action: Notes.Business.Action) async {
        switch action {
            case let .obtainNotesSuccess(notes):
                self.notes = .success(notes)

            case let .obtainNotesFail(err):
                self.notes = .failure(err)

            case let .upsertNoteSuccess(note):
                var currentNotes = self.notes.value ?? []
                currentNotes.upsertByIdentity(note)
                self.notes = .success(currentNotes)

            case .upsertNoteFail:
                break

            case let .deleteNoteSuccess(note):
                var currentNotes = self.notes.value ?? []
                currentNotes.removeById(note)
                self.notes = .success(currentNotes)

            case .deleteNoteFail:
                break
        }
    }
}
