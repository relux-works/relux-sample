# Optional learning exercises

Task: TASK-260909-3kd1i7 — write-learning-exercises. Prepared 2026-09-09 for the later documentation/diagram publisher; board outcome only.

## Source baseline and scope

Read-only inspection of `/Users/iv/Developer/IV/ioscrew-demo/relux-sample/.temp/STORY-260909-q49ois/worktree` at HEAD `93e90201dc8454015fe1018db9c09d0d9c01d287`, initially clean. UI work remains active: paths below exist at inspection, but are not an assertion that the UI implementation is frozen. Recheck paths and commands against the accepted UI head before publishing. No source edits or builds/tests were performed here.

Implemented: Notes fetch/create/update/delete through an in-memory dictionary provider; actor BusinessState with a derived MainActor UIState; Auth in separate products with HybridState; application saga observing logout to clean store state except AppRouter. Durable storage, a session-safe provider reset, a duplicate-note action, and a command-line executable are proposed exercises, not shipped features. Store cleanup does not erase the fetcher's dictionary. Current module wiring constructs the Notes UI projection, so a headless client cannot simply reuse the entire app module unchanged.

Use `N = relux_sample/Modules/Notes` and `T = relux_sampleTests/Notes` in the entry points below. These are path abbreviations, not shell variables.

## 1. Duplicate a note, with reducer and flow tests first

- **User-visible goal (proposed):** “Duplicate” creates a second note with a new identity and creation date, preserving the original title/content and original note.
- **Pattern:** container callback → domain effect/flow → service → success action → reducer → UI projection. Reuse upsert; no new package is needed for one operation. Construct the duplicate under domain rules rather than in presentation code.
- **Entry points:** `N/Business/Model/Notes+Business+Model+Note.swift`, `N/Business/Middleware/Notes+Business+Flow.swift`, `N/Business/Notes+Business+State+Reducer.swift`, `N/UI/Details/Notes+UI+Details+Container.swift`; existing test examples in `T/Business/State/NotesTests+Business+State+Upsert.swift` and `T/Business/Saga/NotesTests+Business+Saga+Upsert.swift` (the Saga directory currently tests a Flow).
- **Acceptance:** Swift Testing proves the original is unchanged, the copy has a distinct ID, and successful upsert inserts exactly one copy. A service failure returns a failed ActionResult, emits the failure action, and inserts no copy; assert state and result, not only logging. Drive the UI callback and verify the displayed list changes after success.
- **Pitfall:** dispatching from a Page/View or maintaining a second editable notes collection as domain truth. Local draft fields are fine; commit through a container callback.

## 2. Keep notes across launches

- **User-visible goal (proposed):** a saved or deleted note stays saved or deleted after relaunch.
- **Pattern:** replace the provider behind `IFetcher`; keep DTO conversion and domain error mapping in the service/provider boundary. An actor-backed file implementation is enough for this exercise; no persistence framework or infrastructure is prescribed.
- **Entry points:** `N/Data/Api/Notes+Data+Api+Fetcher.swift` (`IFetcher`, including its current `deletetNote` spelling), `N/Data/Api/DTO/Notes+Data+Api+DTO+Note.swift`, `N/Business/Middleware/Notes+Business+Service.swift`, `N/Notes+Module.swift` (`buildFetcher`).
- **Acceptance:** write, recreate the provider, read the same note; delete, recreate, verify absence. Missing storage follows an explicit first-run policy; unreadable/corrupt storage fails rather than becoming an empty successful list. Failed writes never emit a successful domain mutation. Test service mapping with a fetcher fake and durability with a temporary real store.
- **Pitfall:** putting file URLs, serialization, or database calls in the Flow/Saga. A logged I/O failure is still failure.

## 3. Make logout cleanup session-safe

- **User-visible goal (proposed strengthening):** after logout, old notes cannot reappear through a reload or a request that finishes late. Choose and document whether durable notes are erased or retained for the same device user; LocalAuthentication is not a multi-account backend identity system.
- **Pattern:** cross-domain orchestration owns ordering; Notes owns provider/session cleanup through an interface. Existing store cleanup is a starting point, not proof of durable erasure or late-result rejection.
- **Entry points:** `relux_sample/Modules/App/Business/SampleApp+Business+Saga.swift`, `Packages/Auth/Sources/AuthReluxImpl/Business/Middleware/Auth+Business+Saga.swift`, `N/Business/Notes+Business+State.swift`, `N/Notes+Module.swift`, `relux_sample/IoC/IoC.swift`.
- **Acceptance:** dispatch the real registered logout entry point; verify provider policy, cleared Notes state/projection, and intended routing. Hold an old-session request, log out, release it, and prove it cannot repopulate state. Include cleanup failure behavior. If ordering is required, implement explicit awaited coordination and prove it; observing the same effect in multiple sagas does not establish subscriber order.
- **Pitfall:** letting Auth import Notes implementation or treating store cleanup as provider deletion. Keep domain dependencies behind interfaces; do not invent SessionOrchestration/DataOrchestration packages merely because older docs mention them.

## 4. Reuse the domain from a headless CLI

- **User-visible goal (proposed):** list, create, and delete notes from a terminal using the same business behavior as the app.
- **Pattern:** extract only the reusable Notes models/interfaces/implementation and necessary utilities into a UI-independent package; compose a business-only module and inject its dispatcher/service. GUI and CLI share that implementation. Package splitting follows actual reuse, ownership, and build boundaries, not a mandatory six-product template.
- **Entry points:** `N/Business/Middleware/Notes+Business+Flow.swift`, `N/Business/Notes+Business+State.swift`, `N/Notes+Module.swift`, `relux_sample/IoC/IoC.swift`, `Packages/Auth/Package.swift` (existing boundary example, not a required layout).
- **Acceptance:** launch the real proposed executable from a shell and exercise list/create/delete against temporary storage. Assert output and exit status; storage errors and malformed input must exit nonzero without reporting success. Observe reducer state after dispatch. Build the business target without SwiftUI, AuthUI, app navigation, or app-global resolver dependencies. Do not fabricate a `swift run` command before its executable target exists.
- **Pitfall:** a CLI that calls a duplicate service implementation and bypasses the shared Flow/reducer, or a supposedly headless module that still creates UIState through app IoC.

## State and module sizing

HybridState is enough for a small domain with modest MainActor work and one straightforward observable state; Auth is the concrete example. BusinessState + UIState is useful when actor-owned work/domain state and independently derived presentation data need separate isolation or consumers; Notes already demonstrates that split. UIState projections are derived representations, never competing mutable truth. Relux's BusinessState protocol requires Sendable reference semantics and async reduction/cleanup, not specifically an actor. Do not split a tiny feature into six packages; the Auth manifest has six products inside one domain package.

## Concise documentation corrections for the publisher

1. Keep README's short setup and verified audit link. Fix `PROJECT_GUIDE.md` claims about nonexistent orchestration packages, removed app Auth paths, forced dynamic products, and “all tests in packages”: Notes currently retains an app-hosted target. Describe CLI as an exercise until implemented.
2. Synchronize Swift tooling with the manifests/audit: Xcode 26+, Swift 6.2+, iOS 17+/macOS 14+ deployment targets. Avoid claiming execution on the oldest supported runtime. Keep README.ru.md as a short Russian pointer to the maintained English guide.
3. Preserve these existing command entry points, choosing a locally installed simulator before testing:
   - `xcrun simctl list devices available`
   - `xcodebuild build -project relux_sample.xcodeproj -scheme relux_sample -destination 'generic/platform=iOS Simulator' -derivedDataPath .temp/DerivedData -disableAutomaticPackageResolution -onlyUsePackageVersionsFromResolvedFile CODE_SIGNING_ALLOWED=NO`
   - `xcodebuild test -project relux_sample.xcodeproj -scheme relux_sample -destination 'platform=iOS Simulator,name=iPhone 17' -derivedDataPath .temp/DerivedData -parallel-testing-enabled NO -disableAutomaticPackageResolution -onlyUsePackageVersionsFromResolvedFile CODE_SIGNING_ALLOWED=NO`
   - Optional macOS package check: `swift test --package-path Packages/Auth --force-resolved-versions`.
   There is no root Package.swift. Commands above are checked against current README/project/package paths and previously reviewed audit evidence; not rerun in this research. The publisher must verify them on the accepted UI revision. New exercise tests/CLI targets will require corresponding command updates.

## Sources and evidence logbook

- Sample sources listed above, plus `README.md`, `PROJECT_GUIDE.md`, `README.ru.md`, `Docs/ArchitectureAudit.md`, and `Packages/Auth/Tests/AuthTests/AuthBasicsTests.swift`. These relative paths resolve from the inspected checkout.
- Reviewed board evidence: `TASK-260909-3hzrc3_review-verdict-rev2.md`, accepted candidate `99cb44b484ec9b843136f1ed54ad1b31c6571b65`. Its carried evidence is 7 Auth tests and 14 Notes tests, not executions by this researcher. It explicitly does not verify logout subscriber interleaving or exhaustive UI behavior.
- [Pinned Relux state contracts](https://github.com/relux-works/swift-relux/blob/483a0f2b6c97721ecb651516e9db9fb83c90cd69/Sources/Relux/Relux/Relux+Store/Relux+State.swift), inspected directly in the audit's local upstream clone; `git rev-parse HEAD` matched that revision. [Pinned dispatcher contract](https://github.com/relux-works/swift-relux/blob/483a0f2b6c97721ecb651516e9db9fb83c90cd69/Sources/Relux/Relux/Relux+Dispatcher/Relux+Dispatcher.swift) is additionally grounded in the verified audit. Browser retrieval of the state source failed with cache miss; no web verification success is claimed.
- Important teaching boundary: logout clears store state but does not clear the provider dictionary; no late-result protection was established. Treat session-safe cleanup as proposed work. UI paths remain subject to the active UI task.
- Readiness logs: sibling `readiness-01.log`. Initial discovery searches returned exit 2 for absent optional skill/search directories; this was a discovery failure, not a test failure or passing gate. Repeated source reads used existing paths. No logbook CLI or repository logbook was discovered; this section is the task's persisted research logbook.
