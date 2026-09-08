import Foundation
import Testing
@testable import relux_sample

@Suite struct NoteProtectionTests {
    typealias Note = Notes.Business.Model.Note

    private func note(_ title: String = "Visible title") -> Note {
        Note(id: UUID(), createdAt: Date(timeIntervalSince1970: 123), title: title, content: "secret body")
    }

    @Test func successUnlocksOnlyRequestedNoteAndRefreshPreservesProtection() async throws {
        let provider = Notes.Data.Api.Fetcher(authenticate: { true })
        let service = Notes.Business.Service(fetcher: provider)
        let a = note(), b = note("Other")
        for n in [a, b] {
            try await service.upsert(note: n).get()
            try await service.setProtection(noteId: n.id, protected: true).get()
        }
        try await service.unlock(noteId: a.id).get()
        let read = try await service.getNotes().get()
        #expect(read.first { $0.id == a.id }?.content == a.content)
        #expect(read.first { $0.id == b.id }?.content == "")
        let edited = Note(id: a.id, createdAt: a.createdAt, title: "Edited", content: "changed secret")
        try await service.upsert(note: edited).get()
        await service.relock(noteId: a.id)
        let refreshed = try await service.getNotes().get()
        #expect(refreshed.first { $0.id == a.id }?.isLocked == true)
        #expect(refreshed.first { $0.id == a.id }?.content == "")
        try await service.unlock(noteId: a.id).get()
        #expect(try await service.getNotes().get().first { $0.id == a.id }?.content == edited.content)
        try await service.setProtection(noteId: a.id, protected: false).get()
        await service.relock(noteId: nil)
        #expect(try await service.getNotes().get().first { $0.id == a.id }?.content == edited.content)
    }

    @Test func rejectedAuthAndLockedMutationPathsFailClosed() async throws {
        let service = Notes.Business.Service(fetcher: Notes.Data.Api.Fetcher(authenticate: { false }))
        let original = note()
        try await service.upsert(note: original).get()
        try await service.setProtection(noteId: original.id, protected: true).get()
        #expect(await service.unlock(noteId: original.id).isFailure)
        #expect(await service.upsert(note: original).isFailure)
        #expect(await service.delete(noteId: original.id).isFailure)
        #expect(await service.setProtection(noteId: original.id, protected: false).isFailure)
        let redacted = try #require(try await service.getNotes().get().first { $0.id == original.id })
        #expect(redacted.title == original.title)
        #expect(redacted.content.isEmpty)
        #expect(redacted.isLocked)
    }

    @Test(arguments: [false, true])
    func lateAuthenticationCannotUndoRevocation(background: Bool) async throws {
        let auth = SuspendedAuthentication()
        let service = Notes.Business.Service(fetcher: Notes.Data.Api.Fetcher(authenticate: { await auth.evaluate() }))
        let original = note()
        try await service.upsert(note: original).get()
        try await service.setProtection(noteId: original.id, protected: true).get()
        let pending = Task { await service.unlock(noteId: original.id) }
        await auth.waitUntilStarted()
        await service.relock(noteId: background ? nil : original.id)
        await auth.resolve(true)
        #expect(await pending.value.isFailure)
        #expect(try await service.getNotes().get().first { $0.id == original.id }?.content == "")
    }

    @Test func cancelledTaskCannotGrantAccess() async throws {
        let auth = SuspendedAuthentication()
        let service = Notes.Business.Service(fetcher: Notes.Data.Api.Fetcher(authenticate: { await auth.evaluate() }))
        let original = note()
        try await service.upsert(note: original).get()
        try await service.setProtection(noteId: original.id, protected: true).get()
        let pending = Task { await service.unlock(noteId: original.id) }
        await auth.waitUntilStarted()
        pending.cancel()
        await auth.resolve(true)
        #expect(await pending.value.isFailure)
    }

    @Test @MainActor func lockedSearchAndEditorProjectionHideBody() async throws {
        let service = Notes.Business.Service(fetcher: Notes.Data.Api.Fetcher(authenticate: { true }))
        let original = note()
        try await service.upsert(note: original).get()
        try await service.setProtection(noteId: original.id, protected: true).get()
        let redacted = try #require(try await service.getNotes().get().first { $0.id == original.id })
        let props = Notes.UI.List.Container.Page.Props(notes: .success([[redacted]]))
        #expect(props.groups(matching: "secret").isEmpty)
        #expect(props.groups(matching: "Visible").count == 1)
        #expect(redacted.editableNote == nil)
    }

    @Test func flowEnforcesProtectionAndPublishesCanonicalSnapshots() async throws {
        let logger = Relux.Testing.Logger()
        let dispatcher = Relux.Dispatcher(logger: logger)
        let service = Notes.Business.Service(fetcher: Notes.Data.Api.Fetcher(authenticate: { false }))
        let flow = await Notes.Business.Flow(dispatcher: dispatcher, svc: service)
        let original = note()
        let created: Relux.Flow.Result = await flow.apply(Notes.Business.Effect.upsert(note: original))
        #expect(created.isSuccess)
        let protected: Relux.Flow.Result = await flow.apply(
            Notes.Business.Effect.setProtection(noteId: original.id, protected: true))
        #expect(protected.isSuccess)
        for effect in [Notes.Business.Effect.unlock(noteId: original.id), .upsert(note: original),
                       .delete(note: original), .setProtection(noteId: original.id, protected: false)] {
            let result: Relux.Flow.Result = await flow.apply(effect)
            #expect(!result.isSuccess)
        }
        let refreshed: Relux.Flow.Result = await flow.apply(Notes.Business.Effect.obtainNotes)
        #expect(refreshed.isSuccess)
        let snapshots = logger.actions.compactMap { action -> Notes.Business.Snapshot? in
            if case .snapshot(let value) = action as? Notes.Business.Action { return value }
            return nil
        }
        let latest = try #require(snapshots.last)
        #expect(latest.notes.first { $0.id == original.id }?.content == "")
        #expect(latest.notes.first { $0.id == original.id }?.isLocked == true)
    }

    @Test func successfulFlowUnlockAndRelockRefreshState() async throws {
        let logger = Relux.Testing.Logger()
        let service = Notes.Business.Service(fetcher: Notes.Data.Api.Fetcher(authenticate: { true }))
        let flow = await Notes.Business.Flow(dispatcher: Relux.Dispatcher(logger: logger), svc: service)
        let original = note()
        for effect in [Notes.Business.Effect.upsert(note: original),
                       .setProtection(noteId: original.id, protected: true), .unlock(noteId: original.id)] {
            let result: Relux.Flow.Result = await flow.apply(effect)
            #expect(result.isSuccess)
        }
        #expect(try await service.getNotes().get().first { $0.id == original.id }?.content == original.content)
        let revoked: Relux.Flow.Result = await flow.apply(Notes.Business.Effect.relock(noteId: nil))
        #expect(revoked.isSuccess)
        #expect(try await service.getNotes().get().first { $0.id == original.id }?.isLocked == true)
    }

    @Test func unprotectedNoteUnlockDoesNotEvaluateAuthentication() async throws {
        let auth = AuthenticationCounter()
        let service = Notes.Business.Service(fetcher: Notes.Data.Api.Fetcher(authenticate: { await auth.evaluate() }))
        let original = note()
        try await service.upsert(note: original).get()
        try await service.unlock(noteId: original.id).get()
        #expect(await auth.count == 0)
        #expect(try await service.getNotes().get().contains(original))
        #expect(await service.unlock(noteId: UUID()).isFailure)
        #expect(await auth.count == 0)
    }

    @Test @MainActor func backgroundRedactsBothUIProjectionsImmediately() async {
        let state = await Notes.UI.State(state: Notes.Business.State())
        let ordinary = note("Ordinary")
        var protected = note()
        protected.isProtected = true
        state.notes = .success([ordinary.id: ordinary, protected.id: protected])
        state.notesGroupedByDay = .success([[ordinary, protected]])
        state.hideProtectedContent()
        #expect(state.note(by: protected.id).value??.content == "")
        #expect(state.note(by: protected.id).value??.editableNote == nil)
        #expect(state.note(by: ordinary.id).value??.content == ordinary.content)
        #expect(state.notesGroupedByDay.value?.first?.last?.content == "")
    }

    @Test func missingNotesCannotBeUnlockedOrHaveProtectionChanged() async {
        let auth = AuthenticationCounter()
        let service = Notes.Business.Service(fetcher: Notes.Data.Api.Fetcher(authenticate: { await auth.evaluate() }))
        let missing = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
        #expect(await service.unlock(noteId: missing).isFailure)
        #expect(await service.setProtection(noteId: missing, protected: false).isFailure)
        #expect(await auth.count == 0)
    }

    @Test func reducerRejectsSnapshotOlderThanRevocation() async {
        let state = Notes.Business.State()
        let original = note()
        await state.reduce(with: Notes.Business.Action.snapshot(.init(revision: 2, notes: [])))
        await state.reduce(with: Notes.Business.Action.snapshot(.init(revision: 1, notes: [original])))
        await state.reduce(with: Notes.Business.Action.snapshot(.init(revision: 2, notes: [original])))
        #expect(await state.notes.value == [])
    }
}

private extension Result {
    var isFailure: Bool { if case .failure = self { true } else { false } }
}

private actor SuspendedAuthentication {
    private var continuation: CheckedContinuation<Bool, Never>?
    private var started: CheckedContinuation<Void, Never>?
    func evaluate() async -> Bool {
        await withCheckedContinuation { continuation in
            self.continuation = continuation
            started?.resume()
            started = nil
        }
    }
    func waitUntilStarted() async {
        if continuation != nil { return }
        await withCheckedContinuation { started = $0 }
    }
    func resolve(_ result: Bool) { continuation?.resume(returning: result); continuation = nil }
}

private actor AuthenticationCounter {
    var count = 0
    func evaluate() -> Bool { count += 1; return true }
}

private extension Relux.ActionResult {
    var isSuccess: Bool { if case .success = self { true } else { false } }
}

@Suite(.serialized) @MainActor
struct NotesModuleProtectionTests {
    @Test func moduleLoadsWithoutAuthenticationAndUsesInjectedAuthForUnlock() async throws {
        let auth = AuthenticationCounter()
        let module = await Notes.Module(authenticate: { await auth.evaluate() })
        let flow = try #require(module.sagas.first as? Notes.Business.IFlow)
        let result: Relux.Flow.Result = await flow.apply(Notes.Business.Effect.obtainNotes)
        #expect(result.isSuccess)
        #expect(await auth.count == 0)
        let note = Notes.Business.Model.Note(id: UUID(), createdAt: .now, title: "Module note", content: "Body")
        for effect in [Notes.Business.Effect.upsert(note: note),
                       .setProtection(noteId: note.id, protected: true), .unlock(noteId: note.id)] {
            let result: Relux.Flow.Result = await flow.apply(effect)
            #expect(result.isSuccess)
        }
        #expect(await auth.count == 1)
    }
}
