# TASK-260909-1b1pyo — review verdict, revision 1

Verdict: accepted
Candidate: CR-TASK-260909-1b1pyo-1 revision 1
Base: 7480ddac95d011be88d6c0edb4e4d9a77090de88
Tree: 6e19864ce5449d0d9ec720bb1384a28b71470070
Repository delta: present; 82 changed paths. A repository change is necessary for this implementation.

No blocking findings within the requested in-memory sample and blind-review scope.
The working files and symlink targets match every blob in the candidate tree.
No product code, candidate tests, branch, index or commits were changed by this reviewer.
The only modified source was an isolated disposable Auth copy under .temp/review-1/attack.

## AC assessment: 10 of 14 behavioral AC rows driven

Reviewed the producer's attached results before code inspection. Retain its honest
10/14 ratio: four UI/system rows are explicitly bounded by the user's prohibition
on UI work, not silently counted as tested. Named tests are in the candidate;
committing them belongs to the subsequent producer integration transaction.

| Row | Production entry / named driving tests |
| --- | --- |
| Load without auth | Notes.Module / Flow.apply: moduleLoadsWithoutAuthenticationAndUsesInjectedAuthForUnlock |
| Redacted body/search/editor inputs | Fetcher.snapshot, Service.getNotes, list Props.groups, Note.editableNote, UI.State.hideProtectedContent: lockedSearchAndEditorProjectionHideBody; backgroundRedactsBothUIProjectionsImmediately; flowEnforcesProtectionAndPublishesCanonicalSnapshots |
| Per-note grants | Service.unlock → Fetcher.unlock: successUnlocksOnlyRequestedNoteAndRefreshPreservesProtection |
| Device-owner policy/context/unavailable | Auth.Service.runLocalAuth: deviceOwnerPolicyReturnsActualBoolean; unavailablePolicyNeverEvaluatesOrAuthorizes; everyRequestCreatesAndInvalidatesItsOwnContext |
| False/error/cancel refusal | Auth.Flow.authenticate, Auth.Service.runLocalAuth, Fetcher.unlock: authorizationFalseReturnsFailure; failedAuthenticationReturnsFailure; cancelledAuthenticationReturnsFailure; unavailableAuthenticationReturnsFailure; taskCancelledDuringAuthenticationCannotSucceed; evaluationErrorsNeverAuthorize; cancelledTaskCannotGrantAccess |
| Refresh/edit retention | Service.upsert/getNotes → Fetcher: successUnlocksOnlyRequestedNoteAndRefreshPreservesProtection |
| Mutation guards and absent IDs | Notes.Flow.apply → Service → Fetcher: rejectedAuthAndLockedMutationPathsFailClosed; flowEnforcesProtectionAndPublishesCanonicalSnapshots; missingNotesCannotBeUnlockedOrHaveProtectionChanged |
| Explicit/all-note relock | Service.relock, Flow.apply: successfulFlowUnlockAndRelockRefreshState; successUnlocksOnlyRequestedNoteAndRefreshPreservesProtection |
| Late auth/snapshot replay | Fetcher.unlock/relock, State.reduce: lateAuthenticationCannotUndoRevocation; reducerRejectsSnapshotOlderThanRevocation |
| Ordinary edits without auth | Service.upsert/unlock: unprotectedNoteUnlockDoesNotEvaluateAuthentication; inMemoryServiceCreateEditDeleteJourney |
| First rendered screen | BOUND: Root.Container and App wiring inspected and iOS compiled, no UI assertion |
| Settings/Account/native controls | BOUND: route/toolbar/page source inspected and compiled, no UI assertion |
| Actual system credential interaction | BOUND: adapter tested with scripted LAContext; no actual biometric/passcode prompt |
| OS scene delivery/rendering | BOUND: background-only handler inspected, domain revocation/redaction tested; actual lifecycle and rendered frame ordering not exercised |

## Independent verification

- swift test --package-path Packages/Auth --force-resolved-versions: exit 0;
  11 Swift tests / 2 suites. Log: auth-tests-01.log.
- xcodebuild test -project relux_sample.xcodeproj -scheme relux_sample
  -destination 'platform=iOS Simulator,name=iPhone 17'
  -derivedDataPath .temp/DerivedData -parallel-testing-enabled NO
  -disableAutomaticPackageResolution -onlyUsePackageVersionsFromResolvedFile
  CODE_SIGNING_ALLOWED=NO: exit 0; 33 Swift tests / 16 suites;
  includes iOS compilation. Log: ios-tests-01.log.
- git diff --check: exit 0, diff-check-01.log. No separate configured linter.
- Candidate blob/symlink comparison: zero mismatches, tree-verification.txt.
- Tool versions: readiness.log. iOS deployment baseline remains 17, macOS 14;
  neither oldest-OS execution nor a fresh macOS app build is claimed.

## Gate attack

Independently reproduced the absent-success-evidence shape in a disposable copy:
changed only Auth.Flow.authenticate's success(false) branch from rejection to
success, keeping error and cancellation refusals in force. Ran:

swift test --package-path .temp/review-1/attack/Packages/Auth
  --force-resolved-versions --filter authorizationFalseReturnsFailure

Exit 1 after successful compilation. The named behavioral test failed with
“False must fail”; narrow-false-01.log records the actual assertion. This is a
narrowing mutant, not gate deletion or a source-token checker.

Accepted the producer's attached raw evidence for the remaining provider,
revocation, redaction, editor and Auth adapter mutations; those were not rerun
by this reviewer. Inspected the mutation records and relevant production call
sites. Producer reports 19/20 probes killed, including a generation +1 narrowing.
The surviving final-note-existence clause is subsumed by generation revocation:
all current deletion/protection changes revoke that note, and unlock also checks
the generation. It is not counted as an independently killed gate. No production
source-text gate was added, so token-preserving static-checker requirements are
not applicable.

The provider is the mutation/access authority; auth is injected at app composition
and Notes does not import AuthServiceImpl or LocalAuthentication. Snapshot versions
reject delayed canonical reads. Old reducer success actions remain reachable by
trusted in-process dispatch but have no current production emitters (searched
callers); arbitrary malicious in-process code is outside this expressly non-encrypted
sample access-lock boundary. This review does not claim tamper resistance against
forged arbitrary Relux actions or memory access.

## Scope / follow-up

No CUA, screenshots, snapshot harness, simulator navigation or UI tests were used.
App-hosted unit tests launch the test host. Broader architecture-guide/diagram
updates belong to the sibling documentation task, as recorded in the producer
handoff; they are not represented as completed here. The retained legacy success
actions can be removed in a subsequent cleanup with their legacy reducer tests.

Reviewer goal query returned “none (run is not goal-bound)”. No operator directives.
Review lifecycle branch is acceptance via accept_cr, never reviewer done/commit_ack.
