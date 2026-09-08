# TASK-260909-3hzrc3 — revision two rework evidence

## Reviewer finding addressed

Corrected the Auth effect inventory and coverage claim from 6 of 6 to **5 of 5** in `Docs/ArchitectureAudit.md` and the task handoff outcome. The authoritative enum declares:

1. `checkAuthContext` — `AuthBehaviorTests.authContextAndLogoutChooseTheirRoutes`
2. `obtainAvailableBiometryType` — `AuthBehaviorTests.registeredModuleReducesBiometryAndCleansUp`
3. `authorizeWithBiometry` — the three `AuthBehaviorTests.authorization*` tests
4. `logout` — `AuthBehaviorTests.authContextAndLogoutChooseTheirRoutes`
5. `runLogoutFlow` — `AuthBehaviorTests.logoutRecreatesContextBeforeRoutingToLocalAuth`

Production entry point: `Relux.Dispatcher.actions -> Auth.Module.sagas -> Auth.Business.Saga.apply`.

## Revision two verification

| Check | Exit | Evidence |
| --- | ---: | --- |
| Source enumeration and documentation assertion | 0 | Exactly five enum cases; all five test dispatch sites present; both audit and handoff say 5 of 5 and contain no stale 6-of-6 claim. |
| Candidate-tree blob comparison | 0 | Checked 172 paths against revision-one candidate tree `17dc14ef98318d74b0dd4772f83e8cbba537b222`; only `Docs/ArchitectureAudit.md` differs; zero extra non-ignored paths. |
| Four lockfile SHA-256 values | 0 | All values match the revision-one reviewer evidence listed below. |
| `git diff --check 17dc14ef98318d74b0dd4772f83e8cbba537b222 --` | 0 | No whitespace errors. |
| Exact audit comparison with `git diff --no-index` | 1 | Expected non-zero: it reports the single intended 6-of-6 to 5-of-5 prose replacement and added test mapping. |

Lockfile hashes remain:

| Lockfile | SHA-256 |
| --- | --- |
| `Packages/Auth/Package.resolved` | `dad943f167fbf192f302b241518b59e0d51a81ff0f0d83273d84abefd71afd97` |
| `Packages/AuthUI/Package.resolved` | `e6a541a60c9ab94037ab084a9434212baa31734890a7ce6f4d139630df8bc93a` |
| `Packages/TestInfrastructure/Package.resolved` | `2b3ce45741060e5a6952b5d20f77901f6a79e8ed9c35ea47aa76a1806f02564a` |
| `relux_sample.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved` | `b68851aec21344d30cb02062109074f240be39ee654e119f5563a0cee7caca57` |

No source, test, manifest, Xcode project, or lockfile changed in revision two. Per the reviewer instruction, full suites were not rerun for this prose-only correction. The prior producer and independent reviewer green test/build/resolver evidence remains applicable because all executable and configuration blobs are unchanged.

## Existing narrowing-mutant evidence retained

| Mutant | What it narrows the gate to | Named test that fails | Survival bound |
| --- | --- | --- | --- |
| Auth false-result admission | Service errors still refuse; only `.success(false)` is admitted to main | `AuthBehaviorTests.authorizationFalseNeverRoutesToMain` (exit 1) | Killed; no survivor |
| Notes obtain-error admission | Errors still fail except `.obtainFailed`; upsert/delete failure handling remains present | `NotesTests.Business.Saga.Obtain.obtainNotes_Failure` (exit 65) | Killed; no survivor |

The mutations were not repeated because revision two does not change their production or test call sites. Overall AC evidence remains **1 of 3 rows driven by named behavioral tests and 3 of 3 rows validated by the appropriate test, resolver/build command, or cited source review**.
