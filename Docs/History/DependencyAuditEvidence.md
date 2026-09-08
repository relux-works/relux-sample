# Dependency audit evidence (historical)

Original TASK-260909-3hzrc3 evidence from 2026-09-09. These are that task’s commands and results, not reruns for the documentation task. Current contracts and pinned source citations remain in [ArchitectureAudit.md](../ArchitectureAudit.md). Later UI changes are outside this historical snapshot.

## Repairs and tests-first evidence

1. Replaced the broken XCTest test importing nonexistent `Auth` / `AuthImplementation` with Swift Testing tests against actual package products. Before the production refactor, `authorizationFalseNeverRoutesToMain` failed through `Relux.Dispatcher.actions -> registered Auth.Module -> Saga.apply`, demonstrating an actual authorization routing defect.
2. Baseline automatic dependency resolution reached current Relux but the self-referencing dynamic Auth products embedded its static runtime repeatedly. The baseline emitted duplicate-class warnings. Removed the self-dependency and forced dynamic linkage, preserving six separate products and their layer boundaries with normal target dependencies. The subsequent package and app runs have no duplicate Relux class warnings. Updated the modular pattern template to match.
3. Removed obsolete Auth embed entries, duplicate product/framework links, null framework entries, the local sibling SwiftUIRelux reference, and a Downloads-relative test plan / nonexistent UI-test reference. These were configuration repairs, not regenerated project output.
4. Strengthened all six existing Notes flow outcome tests to inspect returned ActionResult as well as dispatched actions. `obtainNotes_Failure` failed before its refactor because the flow returned success. The correction preserves error tracking and returns failure. Upsert and delete retain their existing outcomes.
5. Kept iOS 17 and restored the app's documented macOS 14 deployment target. Guarded iOS-only navigation presentation, moved legacy trailing controls to standard toolbar items, and replaced the only UIKit rounded-corner call with the native SwiftUI RoundedRectangle. No screen redesign or new navigation destination was introduced.

## Measured coverage and bounds

Acceptance criteria are split into their three stated rows:

| AC row | Evidence entry point | Named test coverage / bound |
| --- | --- | --- |
| iOS simulator build and relevant Swift tests pass | `xcodebuild build/test`; Auth package `Auth-Package` test scheme | `AuthBehaviorTests` (7 tests) and `NotesTests` (14 tests); build itself is compiler evidence rather than a unit test |
| Dependencies reproducibly resolve | Xcode package resolver and SwiftPM, with lock enforcement | Direct command evidence and unchanged hashes for 4 of 4 locks; no unit test substitutes for the real resolver |
| Audit documents actual verified contracts and changes | Exact-tag source inspection and this document | Manual source/diff review; documentation truth is not attested by a token-search test |

**1 of 3 AC rows driven by named behavioral tests; 3 of 3 rows validated by their appropriate test, command, or source-review entry point.** Two rows are explicitly outside behavioral-test coverage. New Auth test sources are handed off in the uncommitted candidate; the parent owns the commit.

Auth tests drive **5 of 5 declared effects** through registered production module dispatch: `checkAuthContext` and `logout` in `authContextAndLogoutChooseTheirRoutes`, `obtainAvailableBiometryType` in `registeredModuleReducesBiometryAndCleansUp`, `authorizeWithBiometry` in the three `authorization*` tests, and `runLogoutFlow` in `logoutRecreatesContextBeforeRoutingToLocalAuth`. They cover all **3 of 3 authorization outcome classes** (true, false, error). `registeredModuleReducesBiometryAndCleansUp` also verifies state ownership. The logout-flow test checks the reset occurred and routing/action outcomes, but does not claim independently measured interleaving order. Notes tests drive **6 of 6 success/failure operation rows** via the production `Notes.Business.Flow.apply` used by RootSaga. Existing reducer and UI projection tests remain enabled. The Notes flow tests use its injected dispatcher; they do not independently prove absence of a global singleton or drive the whole GUI. The lazy fallback and RootSaga identity corrections were inspected and exercised by app startup, without a dedicated identity assertion.

No source-scanning gate was added. Physical LocalAuthentication, actual iOS 17/macOS 14 runtime execution, screenshots, exhaustive UI navigation, and a complete audit of unchanged historical test helpers are not claimed. Compilation targets iOS 17/macOS 14 using the installed newer SDK/runtime. Existing app-hosted Notes tests were retained; new Auth tests are in a dedicated package target. Broad extraction of Notes is deferred to avoid changing architecture and UI simultaneously.

## Narrowing mutants

| Mutant | What it narrows failure handling to | Named failing test | Real exit | Survival bound |
| --- | --- | --- | ---: | --- |
| Auth false-result admission | Service errors still refuse; only `.success(false)` is admitted to main | `AuthBehaviorTests.authorizationFalseNeverRoutesToMain` | 1 | Killed; no survivor |
| Notes obtain-error admission | Errors still fail except `.obtainFailed`; upsert/delete failure handling remains present | `NotesTests.Business.Saga.Obtain.obtainNotes_Failure` | 65 | Killed; no survivor |

Both were behavioral runs, not deleted checks. The Auth mutant preserved the `.success(true)` token and changed the false branch's actions; the Notes mutant retained `return .failure(err)` and added one admitted error case. Sources were restored byte-for-byte from task-local copies before green reruns. **2 of 2 mutants killed; 0 survivors.** This scope does not constitute mutation coverage of every unchanged upstream or application gate.

## Verification environment and logbook

Xcode 26.5 (`17F42`), Apple Swift 6.3.2, Apple Silicon host; iOS 26.5 simulator iPhone 17 (`46491660-E76A-40D1-9AD8-1CEA45C1F685`). All commands ran in this Story worktree unless the Auth package directory is stated. Raw logs and tag/source evidence are attached to the task; local copies are under `.temp/TASK-260909-3hzrc3/`. No dependency installs outside SwiftPM/Xcode resolution were required.

- Baseline Auth command failed with exit 1 due to obsolete module imports. An initial fixture revision also failed with exit 1 because the original protocol leaked non-Sendable LAContext; that compile error was corrected before recording the behavioral red test. Tests-first Auth run then failed with exit 1 specifically on false-result authorization.
- First iOS build failed with exit 65 on stale dynamic embed copies. One intermediate project edit caused a parse error (exit 74); the project was reconstructed from the clean baseline plus scoped edits, then built successfully. No broken intermediate project was retained.
- First AuthUI macOS build failed with exit 1 on an iOS-only navigation modifier. Mac app builds failed with exit 65 on UIKit and navigation-bar APIs until the platform fixes; subsequent macOS app and standalone AuthUI builds passed.
- Existing Notes suite initially passed (14 tests). Added outcome assertions produced the expected red run (exit 65, `obtainNotes_Failure`), then all 14 passed after correction. Narrowing mutants above produced real non-zero exits; they are not reported as successful tests.
- Final locked Auth macOS suite: exit 0, 7 tests. Final locked iOS Auth suite: exit 0, 7 tests. Final locked iOS app suite: exit 0, 14 tests. macOS app build: exit 0. Standalone locked AuthUI build: exit 0. Locked Xcode resolution: exit 0. Whitespace check: exit 0. No repository-specific lint configuration exists; whitespace/Swift compiler validation is the stated lint bound.
- Xcode emits a metadata-extraction warning because the sample has no AppIntents framework. This is build-tool metadata output, not a source compiler warning. No new unchecked Sendable conformance or warning-suppression flag was introduced. The pre-existing Combine retroactive unchecked conformances remain; broad concurrency redesign is outside the tested delta.

The attached outcome contains the exact command-to-log and exit-code matrix, source-tag evidence, and review handoff. There are no unresolved external blockers for this scope.
