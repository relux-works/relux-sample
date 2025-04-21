import Testing
@testable import relux_sample

@Suite(.timeLimit(.minutes(1)))
struct Notes_UI_ViewState_Tests {
    typealias Model = Notes.Business.Model
    typealias Action = Notes.Business.Action
    typealias BusinessState = Notes.Business.State
    typealias UIState = Notes.UI.State
    typealias Err = Notes.Business.Err

    @Test func initialState() async throws {
        // Arrange
        let businessState = BusinessState()
        let uiState = await UIState(state: businessState)

        // Assert
        guard case .initial = await uiState.notes else {
            Issue.record("notes should be initial")
            return
        }
    }

    @Test func notesGroupedByDayPipeline() async throws {
        // Arrange
        let businessState = BusinessState()
        let uiState = await UIState(state: businessState)

        let date1 = Date.now
        let date2 = date1.add(days: -1)
        let note1 = Model.Note(id: .init(), createdAt: date1, title: "Title 1", content: "Content 1")
        let note2 = Model.Note(id: .init(), createdAt: date2, title: "Title 2", content: "Content 2")
        let note3 = Model.Note(id: .init(), createdAt: date1, title: "Title 3", content: "Content 3")
        let notes: [Model.Note] = [note1, note2, note3]

        let businessAction = Action.obtainNotesSuccess(notes: notes)
        await businessState.reduce(with: businessAction)

        // Assert
        try await withTimeout(for: .seconds(1)) {
            guard let groupedNotes = try await uiState
                .$notesGroupedByDay
                .asAsyncStream
                .next()?
                .value
            else {
                Issue.record("grouped notes should not be nil")
                return
            }

            #expect(groupedNotes.count == 2)
            #expect(groupedNotes[0].contains(note1))
            #expect(groupedNotes[0].contains(note3))
            #expect(groupedNotes[1].contains(note2))
        }
    }

    @Test func notesDictPipeline() async throws {
        // Arrange
        let businessState = BusinessState()
        let uiState = await UIState(state: businessState)

        let date1 = Date.now
        let date2 = date1.add(days: -1)
        let note1 = Model.Note(id: .init(), createdAt: date1, title: "Title 1", content: "Content 1")
        let note2 = Model.Note(id: .init(), createdAt: date2, title: "Title 2", content: "Content 2")
        let note3 = Model.Note(id: .init(), createdAt: date1, title: "Title 3", content: "Content 3")
        let notes: [Model.Note] = [note1, note2, note3]

        let businessAction = Action.obtainNotesSuccess(notes: notes)
        await businessState.reduce(with: businessAction)

        // Assert
        try await withTimeout(for: .seconds(1)) {
            guard let notesDict = try await uiState
                .$notes
                .asAsyncStream
                .next()?
                .value
            else {
                Issue.record("notes dict should not be nil")
                return
            }
            #expect(notesDict == notes.keyed(by: \.id))
        }
    }
}
