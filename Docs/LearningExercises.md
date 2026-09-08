# Learn by extending the demo

Run the app using [README](../README.md#quick-start), then trace the [three diagrams](../diagrams/README.md). Notes currently supports in-memory create, edit, delete and local title/body search. Auth uses system device-owner authentication. None of the four extensions below is shipped behavior.

Auth's small observable HybridState stays on MainActor. Notes separates actor-owned business truth from a derived MainActor UIState. Choose the split for isolation and consumers, not to maximize package count: Auth's six products live in one package, and Notes still lives in the app.

## 1. Duplicate a note

**Goal:** create a second note with a new ID and creation date while retaining title/content and the original note.

Start at the [note model](../relux_sample/Modules/Notes/Business/Model/Notes+Business+Model+Note.swift), [Flow](../relux_sample/Modules/Notes/Business/Middleware/Notes+Business+Flow.swift), [reducer](../relux_sample/Modules/Notes/Business/Notes+Business+State+Reducer.swift), and [Details.Container](../relux_sample/Modules/Notes/UI/Details/Notes+UI+Details+Container.swift). Use the existing upsert path; define duplication rules in the domain and expose a container callback.

Write reducer and Flow tests first: distinct ID, fresh date, unchanged original, exactly one inserted copy. A service failure must return failure and insert nothing. Then drive the callback in the app and verify the list. Use [upsert tests](../relux_sampleTests/Notes/Business/Saga/NotesTests+Business+Saga+Upsert.swift) as a starting point. Avoid dispatch in a Page or a second mutable notes collection in UI.

## 2. Keep notes across launches

**Goal:** saved and deleted notes retain their state after relaunch.

Replace the provider behind [IFetcher](../relux_sample/Modules/Notes/Data/Api/Notes+Data+Api+Fetcher.swift), wired by [Notes.Module](../relux_sample/Modules/Notes/Notes+Module.swift). An actor-backed file provider is sufficient. Keep DTO conversion and domain error mapping at the [service boundary](../relux_sample/Modules/Notes/Business/Middleware/Notes+Business+Service.swift); do not put file operations in the Flow. The current delete method is spelled `deletetNote`.

Write/read/recreate/delete/recreate a temporary real store. Specify first-run behavior for absent storage; unreadable or corrupt storage must fail rather than become a successful empty list. Failed writes must not emit successful domain mutations. Add provider durability tests and service-mapping tests, then relaunch the app against that implementation.

## 3. Make logout cleanup session-safe

**Goal:** notes from a previous session cannot reappear through reload or a late request.

Start at the [app saga](../relux_sample/Modules/App/Business/SampleApp+Business+Saga.swift), [Auth saga](../Packages/Auth/Sources/AuthReluxImpl/Business/Middleware/Auth+Business+Saga.swift), and Notes module/provider. Current store cleanup does not erase the provider dictionary. Decide whether durable notes are erased or retained for the same device user; LocalAuthentication does not define multi-account backend identity.

Expose Notes-owned cleanup through an interface and coordinate it explicitly. Drive registered logout dispatch; verify the chosen provider policy, state/projection cleanup and routing. Hold an old request, log out, release it and prove it cannot repopulate state. Include cleanup failure. Independent subscribers do not establish ordering; see [logout diagram](../diagrams/plantuml/sequence/logout-orchestration.puml). Avoid Auth importing Notes implementation or adding mock-only session guarantees.

## 4. Reuse Notes from a headless CLI

**Goal:** list, create and delete from a terminal through the same business behavior as the GUI.

Extract necessary models, interfaces, implementation and utilities into a UI-independent package. Compose a business-only module with injected dispatcher/service. The current Notes module creates UIState and resolves an app dispatcher; it cannot be reused unchanged. Use [Auth's manifest](../Packages/Auth/Package.swift) as a boundary example, not a mandatory six-product template.

Build the business target without SwiftUI, AuthUI or app navigation. Launch the actual executable against temporary storage and assert output, reducer state and exit status for list/create/delete. Malformed input and storage errors must exit nonzero without success output. Add a documented `swift run` command only after an executable target exists. Do not bypass shared Flow/reducers with a duplicated service-only CLI.

## Review your extension

Use [Testing Strategy](Patterns/TESTING_STRATEGY.md) and the [README commands](../README.md#tools-and-validation). Record exactly what you ran and its exit code. Update diagrams when ownership or runtime ordering changes. Exercises are optional follow-up work, not claims about persistence, session isolation or a CLI in the current sample.
