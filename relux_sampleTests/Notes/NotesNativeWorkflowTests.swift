import Foundation
import Testing
@testable import relux_sample

@Suite struct NotesNativeWorkflowTests {
    typealias Note = Notes.Business.Model.Note
    typealias Draft = Notes.UI.Component.EditForm.Note

    @Test(arguments: ["", " ", "\n\t"])
    func blankTitleCannotBeSaved(title: String) {
        #expect(!Draft(title: title, content: "A useful body").valid)
    }

    @Test(arguments: ["", " ", "\n\t"])
    func blankBodyCannotBeSaved(body: String) {
        #expect(!Draft(title: "A useful title", content: body).valid)
    }

    @Test func editedDraftPreservesIdentityAndDate() {
        let original = Note(id: UUID(), createdAt: Date(timeIntervalSince1970: 123),
                            title: "Original", content: "Before")
        var draft = Draft(from: original)
        draft.title = "After"
        let edited = draft.asNote(withId: original.id)
        #expect(edited.id == original.id)
        #expect(edited.createdAt == original.createdAt)
        #expect(edited.title == "After")
        #expect(draft.valid)
    }

    @Test func inMemoryServiceCreateEditDeleteJourney() async throws {
        let service = Notes.Business.Service(fetcher: Notes.Data.Api.Fetcher())
        let initial = try await service.getNotes().get()
        #expect(!initial.isEmpty)
        let note = Note(id: UUID(), createdAt: Date(timeIntervalSince1970: 123),
                        title: "Weekend plan", content: "Walk by the river")
        try await service.upsert(note: note).get()
        #expect(try await service.getNotes().get().contains(note))
        let edited = Note(id: note.id, createdAt: note.createdAt, title: "Sunday plan", content: "Pack a picnic")
        try await service.upsert(note: edited).get()
        let updated = try await service.getNotes().get()
        #expect(updated.filter { $0.id == note.id } == [edited])
        try await service.delete(noteId: note.id).get()
        #expect(try await service.getNotes().get() == initial)
    }
}

extension NotesNativeWorkflowTests {
    @Test(arguments: [(" ", "Body"), ("\n\t", "Body"), ("Title", " "), ("Title", "\n\t")])
    func flowRejectsBlankContentWithoutChangingStorage(title: String, body: String) async throws {
        let logger = Relux.Testing.Logger()
        let dispatcher = Relux.Dispatcher(logger: logger)
        let service = Notes.Business.Service(fetcher: Notes.Data.Api.Fetcher())
        let initial = try await service.getNotes().get()
        let flow = await Notes.Business.Flow(dispatcher: dispatcher, svc: service)
        let note = Note(id: UUID(), createdAt: Date(timeIntervalSince1970: 123), title: title, content: body)
        let result: Relux.Flow.Result = await flow.apply(Notes.Business.Effect.upsert(note: note))
        guard case .failure = result else {
            Issue.record("Blank content must fail through the production flow and service")
            return
        }
        #expect(logger.getAction(Notes.Business.Action.upsertNoteSuccess(note: note)) == nil)
        #expect(try await service.getNotes().get() == initial)
    }

    @Test @MainActor func searchMatchesTitleAndBodyAndRemovesEmptySections() {
        let date = Date(timeIntervalSince1970: 123)
        let titleMatch = Note(id: UUID(), createdAt: date, title: "Café checklist", content: "Coffee beans")
        let bodyMatch = Note(id: UUID(), createdAt: date, title: "Weekend", content: "Visit a café")
        let excluded = Note(id: UUID(), createdAt: date, title: "Architecture", content: "Reducers")
        let props = Notes.UI.List.Container.Page.Props(notes: .success([[titleMatch, excluded], [bodyMatch]]))
        #expect(props.groups(matching: " CAFE ") == [[titleMatch], [bodyMatch]])
        #expect(props.groups(matching: "reducers") == [[excluded]])
        #expect(props.groups(matching: "unmatched").isEmpty)
        #expect(props.groups(matching: " \n ") == [[titleMatch, excluded], [bodyMatch]])
        #expect(Notes.UI.List.Container.Page.Props(notes: .failure(.notImplemented)).groups(matching: "").isEmpty)
    }
}

extension NotesNativeWorkflowTests {
    @Test @MainActor func saveButtonPropsTrackChangesBetweenValidDrafts() {
        typealias Props = Notes.UI.Component.EditForm.SaveButton.Props
        let date = Date(timeIntervalSince1970: 123)
        let before = Props(draft: Draft(title: "Title", content: "Before", createdAt: date), enabled: true)
        let after = Props(draft: Draft(title: "Title", content: "After", createdAt: date), enabled: true)
        #expect(before != after)
    }
}
