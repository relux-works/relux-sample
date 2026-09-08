# Learn by extending the demo

Run the app using [README](../README.md#quick-start), then trace the [three diagrams](../diagrams/README.md). Notes currently supports in-memory create, edit, delete and local title/body search. Auth uses system device-owner authentication. None of the four extensions below is shipped behavior.

Auth returns a reusable authentication outcome without global login state. Notes separates actor-owned business truth from a derived MainActor UIState. Choose the split for isolation and consumers, not to maximize package count: Auth's six products live in one package, and Notes still lives in the app.

## 1. Duplicate a note

**Goal:** create a second note with a new ID and creation date while retaining title/content and the original note.

Start at the [note model](../relux_sample/Modules/Notes/Business/Model/Notes+Business+Model+Note.swift), [Flow](../relux_sample/Modules/Notes/Business/Middleware/Notes+Business+Flow.swift), [reducer](../relux_sample/Modules/Notes/Business/Notes+Business+State+Reducer.swift), and [Details.Container](../relux_sample/Modules/Notes/UI/Details/Notes+UI+Details+Container.swift). Use the existing upsert path; define duplication rules in the domain and expose a container callback.

Write reducer and Flow tests first: distinct ID, fresh date, unchanged original, exactly one inserted copy. Define whether an accessible protected source produces a protected copy; reject duplication of a locked source. A service failure must return failure and insert nothing. Then drive the callback in the app and verify the list. Use [upsert tests](../relux_sampleTests/Notes/Business/Saga/NotesTests+Business+Saga+Upsert.swift) as a starting point. Avoid dispatch in a Page or a second mutable notes collection in UI.

## 2. Keep notes across launches

**Goal:** saved and deleted notes retain their state after relaunch.

Replace the provider behind [IFetcher](../relux_sample/Modules/Notes/Data/Api/Notes+Data+Api+Fetcher.swift), wired by [Notes.Module](../relux_sample/Modules/Notes/Notes+Module.swift). Define durable protection metadata and keep grants transient; persistence alone does not encrypt bodies. An actor-backed file provider is a starting point. Keep DTO conversion and domain error mapping at the [service boundary](../relux_sample/Modules/Notes/Business/Middleware/Notes+Business+Service.swift); do not put file operations in the Flow. The current delete method is spelled `deletetNote`.

Write/read/recreate/delete/recreate a temporary real store. Specify first-run behavior for absent storage; unreadable or corrupt storage must fail rather than become a successful empty list. Failed writes must not emit successful domain mutations. Add provider durability tests and service-mapping tests, then relaunch the app against that implementation.

## 3. Add timed per-note access expiry

**Goal:** an unlocked protected note relocks after an explicitly chosen interval, including while its editor is open.

Start with the [protection pattern](Patterns/NOTE_PROTECTION.md). Manual/background revocation and late-result generations already exist; expiry does not. Define whether the interval starts at authentication or last interaction, inject a clock into the provider, and reuse Notes-owned revocation and snapshot publication.

Verify just-before/at-deadline behavior, independent note deadlines, editor redaction, and an authentication request held across expiry. Advancing a fake clock must drive the same production expiry path. Do not hide expiry only in UI or introduce global login state.

## 4. Reuse Notes from a headless CLI

**Goal:** list, create and delete from a terminal through the same business behavior as the GUI.

Extract necessary models, interfaces, implementation and utilities into a UI-independent package. Compose a business-only module with injected dispatcher/service. The current Notes module creates UIState and resolves an app dispatcher; it cannot be reused unchanged. Use [Auth's manifest](../Packages/Auth/Package.swift) as a boundary example, not a mandatory six-product template.

Build the business target without SwiftUI or app navigation. Launch the actual executable against temporary storage and assert output, reducer state and exit status for list/create/delete. Malformed input and storage errors must exit nonzero without success output. Add a documented `swift run` command only after an executable target exists. Do not bypass shared Flow/reducers with a duplicated service-only CLI.

## Review your extension

Use [Testing Strategy](Patterns/TESTING_STRATEGY.md) and the [README commands](../README.md#tools-and-validation). Record exactly what you ran and its exit code. Update diagrams when ownership or runtime ordering changes. Exercises are optional follow-up work, not claims about persistence, session isolation or a CLI in the current sample.
