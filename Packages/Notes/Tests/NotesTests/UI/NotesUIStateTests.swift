import Testing
import NotesReluxImpl
import NotesTestSupport
import NotesReluxInt
import Foundation

@Suite
struct NotesUIStateTests {
    @Test
    func groups_notes_by_day_and_ids() async throws {
        let businessState = Notes.Business.State()
        let uiState = await Notes.UI.State(state: businessState)

        let today = Date()
        let yesterday = today.adding(days: -1)

        let note1 = Notes.Business.Model.Note.stub(createdAt: today, title: "A")
        let note2 = Notes.Business.Model.Note.stub(createdAt: today, title: "B")
        let note3 = Notes.Business.Model.Note.stub(createdAt: yesterday, title: "C")

        await businessState.reduce(with: Notes.Business.Action.obtainNotesSuccess(notes: [note1, note2, note3]))

        // Give Combine pipeline a moment to propagate.
        try await Task.sleep(nanoseconds: 100_000_000)

        let groupedState = await MainActor.run { uiState.notesGroupedByDay }
        guard case let .success(grouped) = groupedState else {
            Issue.record("Expected grouped notes to be success")
            return
        }

        let notesState = await MainActor.run { uiState.notes }
        guard case let .success(dict) = notesState else {
            Issue.record("Expected notes dictionary to be success")
            return
        }

        #expect(grouped.count == 2)
        #expect(grouped[0].count == 2)
        #expect(grouped[1].count == 1)
        #expect(dict[note1.id] == note1)
        #expect(dict[note3.id] == note3)
    }
}
