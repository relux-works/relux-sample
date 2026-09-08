# TASK-260909-1b1pyo — developer handoff

Candidate is ready for review, uncommitted on the managed Story branch at
`7480ddac95d011be88d6c0edb4e4d9a77090de88`. HEAD is unchanged and HEAD..main was 0.
The parent owns signed commits, PR publication and landing. Tests named below
are in the candidate; this worker has not claimed they are already committed.

## Implemented behavior

- Notes is the navigation root; Settings opens from its toolbar and contains Account.
  Removed the landing screen, AuthUI package, global login/logout routes, state,
  startup saga and router adapter. Kept Auth’s six products as a reusable Flow/service boundary.
- Auth Service uses deviceOwnerAuthentication and a fresh LAContext for each request,
  invalidating it afterward. An internal test-only constructor injects scripted
  contexts; public construction always creates system LAContext instances.
- Notes provider owns protection metadata, grants and per-note generations.
  Protect locks immediately; unlock grants only the requested note. Locked reads
  redact bodies. Provider guards reject edit/delete/remove-lock and missing IDs.
  Edits cannot overwrite provider metadata. Relock/background revoke grants and
  invalidate pending auth. Versioned snapshots reject older/equal-revision replay.
- Editor navigation carries identity and resolves current access. Background removes
  presentation content and drafts while revocation runs; inactive is untouched.
- Wrote `.spec/note-protection.md` before implementation. Updated README. Per the
  operator directive, broader Docs/PROJECT_GUIDE/diagram edits were removed from
  this candidate; the sibling documentation task owns their now-stale AuthUI,
  logout, old success-action and HybridState descriptions/links.

This remains an in-memory access lock, not encryption or persistent storage.

## Verification

All gates below were run by this worker. No prior attached evidence is being
substituted for these results. Commands ran directly with file redirection, no tee.
Xcode 26.5 (17F42), Swift 6.3.2; Notes tests used iPhone 17 / iOS 26.5 simulator.
Auth package tests ran on this Mac. Deployment targets remain iOS 17/macOS 14;
oldest runtime execution and a new macOS app build are not claimed.

| Gate | Actual exit | Result / log |
| --- | ---: | --- |
| `swift test --package-path Packages/Auth --force-resolved-versions` | 0 | 11 tests / 2 suites; `auth-final-02.log` |
| iOS app `xcodebuild test` (command below) | 0 | 33 tests / 16 suites; `tests-final-02.log` |
| iOS app `xcodebuild build` (command below) | 0 | `build-final-01.log` |
| `git diff --check` | 0 | `lint-final-02.log`; no configured standalone linter |
| `python3 .temp/TASK-260909-1b1pyo/check-doc-links.py` | 0 | 15 local targets in README/spec; `doc-links-final-02.log` |

```sh
xcodebuild test -project relux_sample.xcodeproj -scheme relux_sample   -destination 'platform=iOS Simulator,name=iPhone 17'   -derivedDataPath .temp/DerivedData -parallel-testing-enabled NO   -disableAutomaticPackageResolution -onlyUsePackageVersionsFromResolvedFile   CODE_SIGNING_ALLOWED=NO

xcodebuild build -project relux_sample.xcodeproj -scheme relux_sample   -destination 'generic/platform=iOS Simulator' -derivedDataPath .temp/DerivedData   -disableAutomaticPackageResolution -onlyUsePackageVersionsFromResolvedFile   CODE_SIGNING_ALLOWED=NO
```

## AC coverage — 10 of 14 behavioral rows driven

The table separates deterministic production entry coverage from the explicitly
forbidden native UI work. Build/test/no-UI-work constraints are recorded above
and below, rather than counted as simulated product behavior.

| AC row | Production call site | Named test or stated bound |
| --- | --- | --- |
| Initial module load without authentication | `Notes.Module` → `Notes.Business.Flow.apply(.obtainNotes)` | `moduleLoadsWithoutAuthenticationAndUsesInjectedAuthForUnlock` |
| Locked bodies redacted from read/search/editor inputs | `Fetcher.snapshot`, `Service.getNotes`, list `Props.groups`, `Note.editableNote`, `UI.State.hideProtectedContent` | `lockedSearchAndEditorProjectionHideBody`, `backgroundRedactsBothUIProjectionsImmediately`, `flowEnforcesProtectionAndPublishesCanonicalSnapshots` |
| Authentication grants only requested note | `Service.unlock` → `Fetcher.unlock` | `successUnlocksOnlyRequestedNoteAndRefreshPreservesProtection` |
| Device-owner policy, context freshness and unavailability | `Auth.Business.Service.runLocalAuth` | `deviceOwnerPolicyReturnsActualBoolean`, `unavailablePolicyNeverEvaluatesOrAuthorizes`, `everyRequestCreatesAndInvalidatesItsOwnContext` (scripted LAContext) |
| False/failure/cancellation never authorize | `Auth.Flow.authenticate/apply`, `Auth.Service.runLocalAuth`, `Fetcher.unlock` | `authorizationFalseReturnsFailure`, `failedAuthenticationReturnsFailure`, `cancelledAuthenticationReturnsFailure`, `unavailableAuthenticationReturnsFailure`, `taskCancelledDuringAuthenticationCannotSucceed`, `evaluationErrorsNeverAuthorize`, `cancelledTaskCannotGrantAccess` |
| Protection retained across refresh/edit | `Service.upsert/getNotes` → provider metadata | `successUnlocksOnlyRequestedNoteAndRefreshPreservesProtection` |
| Locked editing/deletion/removal refused | `Notes.Flow.apply` → Service → provider mutation methods | `rejectedAuthAndLockedMutationPathsFailClosed`, `flowEnforcesProtectionAndPublishesCanonicalSnapshots`; missing IDs: `missingNotesCannotBeUnlockedOrHaveProtectionChanged` |
| Manual and all-note revocation operation | `Service.relock(id/nil)`, `Flow.apply(.relock)` | `successfulFlowUnlockAndRelockRefreshState`, `successUnlocksOnlyRequestedNoteAndRefreshPreservesProtection` |
| Late auth and older snapshot cannot restore access | `Fetcher.unlock/relock`, `State.reduce(.snapshot)` | `lateAuthenticationCannotUndoRevocation` (manual/background cases), `reducerRejectsSnapshotOlderThanRevocation` |
| Ordinary notes editable without auth | `Service.upsert/unlock`, module Flow | `unprotectedNoteUnlockDoesNotEvaluateAuthentication`, `inMemoryServiceCreateEditDeleteJourney` |
| Actual first rendered Notes screen and absence of landing screen | `Root.Container.content`, `App.appContent`, route enum | BOUND: source reviewed and compiled; no launch/UI assertion |
| Native Settings/Account/control presentation | Notes toolbar, `Root.handleRoute`, Settings/Details pages | BOUND: source reviewed and compiled; no rendered/tapped UI assertion |
| Real biometric/device-credential system interaction | Public Auth Service with native LAContext | BOUND: policy/adapter behavior is unit tested; physical/system prompt behavior and credential fallback UX are not exercised |
| Actual OS background/inactive delivery and frame/draft removal | `Root.Container.onChange(scenePhase)`, `Edit.Container` | BOUND: domain revocation and immediate UI-state redaction tested; real lifecycle delivery/rendering/Combine interleavings not UI-tested |

No CUA, screenshots, snapshots, simulator navigation, or UI tests were run.
App-hosted Swift unit tests do launch their test host, as required by this target.

## Mutation evidence

20 probes: **19 have named failing tests; 1 survived**. Eighteen failures are
narrowing refusal probes; credential-fallback is an additional policy regression
probe. Expected-red xcodebuild gates really exited 65; Swift gates really exited 1.
The surviving probe exited 0 and is not counted as a killed mutant. No source-text
runtime gate was introduced. The harness changes behavior and runs the behavioral
suite; it never uses a token-presence checker as the result.

| Mutant | What changes / narrows | Named failing test | Actual gate exit | Survivor bound |
| --- | --- | --- | ---: | --- |
| `auth-cancelled-task` | Accepts an in-flight cancelled task if its service returns true | `taskCancelledDuringAuthenticationCannotSucceed()` | 1 | — |
| `auth-cancelled` | Accepts only the cancelled domain error | `cancelledAuthenticationReturnsFailure()` | 1 | — |
| `auth-credential-fallback` | Additional regression probe: evaluates biometrics-only instead of device-owner policy; other deviceOwnerAuthentication tokens remain | `deviceOwnerPolicyReturnsActualBoolean(success:)` | 1 | — |
| `auth-false` | Accepts only the false service result while preserving error refusal | `authorizationFalseReturnsFailure()` | 1 | — |
| `auth-policy-unavailable` | Bypasses unavailable policy only for passcodeNotSet | `unavailablePolicyNeverEvaluatesOrAuthorizes(code:)` | 1 | — |
| `auth-unavailable` | Accepts only the unavailable domain error | `unavailableAuthenticationReturnsFailure()` | 1 | — |
| `cancelled-task` | Accepts a cancelled task for that note | `cancelledTaskCannotGrantAccess()` | 65 | — |
| `cross-note` | Allows Other to use another note’s grant | `successUnlocksOnlyRequestedNoteAndRefreshPreservesProtection()` | 65 | — |
| `editor` | Allows the locked Visible title note into editableNote | `lockedSearchAndEditorProjectionHideBody()`; `backgroundRedactsBothUIProjectionsImmediately()` | 65 | — |
| `false-auth` | Accepts a false authentication result for that note | `rejectedAuthAndLockedMutationPathsFailClosed()`; `flowEnforcesProtectionAndPublishesCanonicalSnapshots()` | 65 | — |
| `late-generation` | Accepts a result exactly one revocation generation late | `lateAuthenticationCannotUndoRevocation(background:)` | 65 | — |
| `late-note-existence` | Allows a missing record through the final record clause, retaining authentication/cancellation/generation guards | None | 0 | SURVIVOR: admitting a missing record after evaluation is still refused by the generation check. Every current deletion/protection change advances generation; this does not establish safety for a future provider mutation that forgets to revoke. The clause has no independent named failing test. |
| `locked-delete` | Allows that locked note through deletion | `rejectedAuthAndLockedMutationPathsFailClosed()`; `flowEnforcesProtectionAndPublishesCanonicalSnapshots()` | 65 | — |
| `locked-upsert` | Allows the locked Visible title note through upsert | `rejectedAuthAndLockedMutationPathsFailClosed()`; `flowEnforcesProtectionAndPublishesCanonicalSnapshots()` | 65 | — |
| `metadata` | Allows the Edited note to replace provider protection with editor metadata | `successUnlocksOnlyRequestedNoteAndRefreshPreservesProtection()` | 65 | — |
| `missing-protection` | Treats that nonexistent UUID as successful protection change | `missingNotesCannotBeUnlockedOrHaveProtectionChanged()` | 65 | — |
| `missing-unlock` | Treats one nonexistent UUID as successful unlock | `missingNotesCannotBeUnlockedOrHaveProtectionChanged()` | 65 | — |
| `redaction` | Exposes only the locked Visible title body | `rejectedAuthAndLockedMutationPathsFailClosed()`; `lateAuthenticationCannotUndoRevocation(background:)`; `lockedSearchAndEditorProjectionHideBody()`; `flowEnforcesProtectionAndPublishesCanonicalSnapshots()` | 65 | — |
| `remove-lock` | Allows that locked note through protection changes | `rejectedAuthAndLockedMutationPathsFailClosed()`; `flowEnforcesProtectionAndPublishesCanonicalSnapshots()` | 65 | — |
| `snapshot-replay` | Accepts an equal-revision snapshot replay | `reducerRejectsSnapshotOlderThanRevocation()` | 65 | — |

Raw mutation JSON records include exact file replacements, commands and gate
exit codes; logs contain the named assertion failures. The harness itself returns
0 after recording an expected-red gate; that wrapper status is not represented
as a passing validation. It restores exact original source bytes in `finally`.
Notes probes use the app test command with
`-only-testing:relux_sampleTests/NoteProtectionTests`; Auth probes use the package
command. Earlier probes ran the focused suites as they existed during development;
all source mutations were restored and the current full suites rerun afterward.

## Development logbook and non-green attempts

- Tests/spec preceded behavioral implementation. `tests-before-01.log` exited 65
  at missing protection APIs; `auth-before-01.log` exited 1 at missing Flow APIs.
  These are expected-red compilation failures, not passing baseline behavior.
- `tests-after-01.log` exited 74 after an overly broad project-reference edit.
  Rebuilt the scoped edit from the unchanged HEAD file; no foreign work was reset.
  `tests-after-02/03.log` exited 65 because deleting AuthUI removed the transitive
  SwiftUIRelux/Router products. Added the same pinned SwiftUIRelux 9.0.0 directly.
  `tests-after-04/05.log` exited 0.
- `tests-after-06.log` exited 65: a test attempted a second Relux instance in its
  hosted app. Reworked it to exercise the module Flow in the existing host.
  `tests-after-07.log` and both `tests-final` runs exited 0.
- `auth-context-before-01.log` exited 1: missing test constructor and a malformed
  optional assertion. `auth-context-after-01.log` exited 1 on that assertion;
  corrected it. `auth-context-after-02.log` and `auth-final-02.log` exited 0.
- Two Auth mutant preparations initially exited 1 at an ambiguous source-match
  assertion before running any gate. Scoped the replacement to `authenticate`
  and reran both; the attached JSON/logs are the real failing gate executions.
- Compiler emitted the standard AppIntents metadata-extraction skip warning;
  no AppIntents dependency exists. It did not fail compilation.
- No logbook CLI/connector/file or board logbook mutation is available. Durable
  development logbook entries were appended through task-board `set_notes` and
  are repeated here. Operator nudge to finalize focused work was honored; no new
  broad campaigns or UI work were started, and broader docs edits were removed.
- The internal LAContext factory is the only test seam added to the native adapter.
  It introduces no public authentication bypass, fallback identity or mock default.

Parent/sibling follow-up: update the historical AuthUI/logout diagrams and pattern
guides for this new code. This implementation handoff deliberately does not claim
that separate documentation task.
