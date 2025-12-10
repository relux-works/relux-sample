import Testing
import NotesReluxImpl
import NotesTestSupport
import NotesReluxInt
import TestInfrastructure

@Suite
struct NotesStateTests {
    @Test
    func initial_state_is_empty() async {
        let state = Notes.Business.State()
        let current = await state.notes
        #expect(current == .initial())
    }

    @Test
    func obtain_notes_success_updates_state() async {
        let state = Notes.Business.State()
        let notes: [Notes.Business.Model.Note] = .stub(count: 2)

        await state.reduce(with: Notes.Business.Action.obtainNotesSuccess(notes: notes))

        let current = await state.notes
        #expect(current == .success(notes))
    }

    @Test
    func obtain_notes_failure_sets_error() async {
        let state = Notes.Business.State()
        let err: Notes.Business.Err = .obtainFailed(cause: StubError())

        await state.reduce(with: Notes.Business.Action.obtainNotesFail(err: err))

        let current = await state.notes
        #expect(current == .failure(err))
    }

    @Test
    func upsert_inserts_or_updates_note() async {
        let state = Notes.Business.State()
        let initial: [Notes.Business.Model.Note] = .stub(count: 1)
        await state.reduce(with: Notes.Business.Action.obtainNotesSuccess(notes: initial))

        let updated = Notes.Business.Model.Note(
            id: initial[0].id,
            createdAt: initial[0].createdAt,
            title: "Updated",
            content: "Updated"
        )

        await state.reduce(with: Notes.Business.Action.upsertNoteSuccess(note: updated))

        let current = await state.notes
        #expect(current.value == [updated])
    }

    @Test
    func delete_removes_note() async {
        let state = Notes.Business.State()
        let initial: [Notes.Business.Model.Note] = .stub(count: 2)
        await state.reduce(with: Notes.Business.Action.obtainNotesSuccess(notes: initial))

        let toDelete = initial.first!
        await state.reduce(with: Notes.Business.Action.deleteNoteSuccess(note: toDelete))

        let current = await state.notes
        #expect(current.value?.contains(toDelete) == false)
        #expect(current.value?.count == 1)
    }
}
