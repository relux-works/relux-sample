# TASK-260909-3hzrc3 — ready for review

Candidate remains UNCOMMITTED at baseline `815a681105ed40c9846ac62c7c123c1250c1eb84`. Parent owns PR and signed delivery. No publication attempted.

Updated all five external dependencies to the verified latest stable tags, added four reproducible lockfiles, removed HttpClient root debris, repaired Xcode linkage/test configuration, and restored macOS 14 compatibility. Auth false outcomes no longer route to main; Notes obtain failures now return failure. LAContext remains private to the service actor. Existing screens are retained.

See `Docs/ArchitectureAudit.md` (copied below) for exact revisions, source contracts, test-first evidence, and the logbook. Attached evidence archive includes raw logs, upstream tag inventories and source/manifest snapshots, lockfile hashes, and this command matrix. The revision-one producer ran every listed command directly, and the revision-one reviewer independently reran Auth and Notes tests, the macOS build, and locked resolution. Revision two changes documentation only, so it preserves and reuses that green evidence rather than rerunning the full suites.

## Revision two reviewer correction

The Auth effect inventory is corrected from 6 of 6 to **5 of 5**. The normative enum declares `checkAuthContext`, `obtainAvailableBiometryType`, `authorizeWithBiometry`, `logout`, and `runLogoutFlow`; the mapping to named tests is recorded in the measured-coverage section below.

A blob comparison against revision one's candidate tree `17dc14ef98318d74b0dd4772f83e8cbba537b222` checked 172 repository paths. `Docs/ArchitectureAudit.md` was the only mismatch and there were zero extra non-ignored paths. All source, test, project/configuration, and lockfile bytes therefore remain unchanged. The four lock SHA-256 values match revision-one reviewer evidence. The enumeration/document assertion and `git diff --check` both exited 0. The exact audit comparison exited 1 as expected because it found the single intended prose replacement. No full build or test suite was rerun for this prose-only correction, per the revision-two scope.

## Command evidence

Commands ran directly without tee or pipe chains. Logs capture stdout/stderr. Exit codes below are the real process codes returned by the execution tool, including expected-red runs. `cwd` is the managed Story worktree except explicit `cd Packages/Auth` commands.

| Log | Command | Exit | Interpretation |
| --- | --- | ---: | --- |
| `auth-baseline-01.log` | `swift test --package-path Packages/Auth` | 1 | Broken pre-existing module imports; compile failure, not passing tests. |
| `auth-before-refactor-02.log` | `swift test --package-path Packages/Auth` | 1 | Initial fixture exposed non-Sendable LAContext in protocol; compilation failure. |
| `auth-before-refactor-03.log` | `swift test --package-path Packages/Auth` | 1 | Expected red: authorizationFalseNeverRoutesToMain; duplicate-class warnings also reproduced. |
| `auth-after-04.log` | `swift test --package-path Packages/Auth` | 0 | 6 tests after auth and linkage correction. |
| `auth-green-05.log` | `swift test --package-path Packages/Auth` | 0 | 7 tests including all Auth effects. |
| `auth-final-06.log` | `swift test --package-path Packages/Auth --force-resolved-versions` | 0 | 7 tests; restored source after mutation. |
| `project-baseline-01.log` | `xcodebuild -list -project relux_sample.xcodeproj` | 0 | Baseline package graph discovery. |
| `ios-build-02.log` | `xcodebuild build -project relux_sample.xcodeproj -scheme relux_sample -destination 'platform=iOS Simulator,id=46491660-E76A-40D1-9AD8-1CEA45C1F685' -derivedDataPath .temp/TASK-260909-3hzrc3/DerivedData CODE_SIGNING_ALLOWED=NO` | 65 | Stale dynamic embed entries. |
| `ios-build-03.log` | `xcodebuild build -project relux_sample.xcodeproj -scheme relux_sample -destination 'platform=iOS Simulator,id=46491660-E76A-40D1-9AD8-1CEA45C1F685' -derivedDataPath .temp/TASK-260909-3hzrc3/DerivedData CODE_SIGNING_ALLOWED=NO` | 74 | Intermediate project parse error; corrected before handoff. |
| `ios-build-04.log` | `xcodebuild build -project relux_sample.xcodeproj -scheme relux_sample -destination 'platform=iOS Simulator,id=46491660-E76A-40D1-9AD8-1CEA45C1F685' -derivedDataPath .temp/TASK-260909-3hzrc3/DerivedData CODE_SIGNING_ALLOWED=NO` | 0 | iOS build after configuration repair. |
| `ios-build-final-05.log` | `xcodebuild build -project relux_sample.xcodeproj -scheme relux_sample -destination 'generic/platform=iOS Simulator' -derivedDataPath .temp/TASK-260909-3hzrc3/DerivedData -disableAutomaticPackageResolution -onlyUsePackageVersionsFromResolvedFile CODE_SIGNING_ALLOWED=NO` | 0 | Final locked iOS simulator build. |
| `ios-test-01.log` | `xcodebuild test -project relux_sample.xcodeproj -scheme relux_sample -destination 'platform=iOS Simulator,id=46491660-E76A-40D1-9AD8-1CEA45C1F685' -derivedDataPath .temp/TASK-260909-3hzrc3/DerivedData -parallel-testing-enabled NO CODE_SIGNING_ALLOWED=NO` | 0 | 14 existing Notes tests. |
| `notes-before-refactor-02.log` | `xcodebuild test -project relux_sample.xcodeproj -scheme relux_sample -destination 'platform=iOS Simulator,id=46491660-E76A-40D1-9AD8-1CEA45C1F685' -derivedDataPath .temp/TASK-260909-3hzrc3/DerivedData -parallel-testing-enabled NO -only-testing:relux_sampleTests/NotesTests/Business/Saga CODE_SIGNING_ALLOWED=NO` | 65 | Expected red: 6 flow tests run; obtainNotes_Failure catches false success. |
| `ios-test-green-03.log` | `xcodebuild test -project relux_sample.xcodeproj -scheme relux_sample -destination 'platform=iOS Simulator,id=46491660-E76A-40D1-9AD8-1CEA45C1F685' -derivedDataPath .temp/TASK-260909-3hzrc3/DerivedData -parallel-testing-enabled NO CODE_SIGNING_ALLOWED=NO` | 0 | 14 tests after flow correction. |
| `ios-final-04.log` | `xcodebuild test -project relux_sample.xcodeproj -scheme relux_sample -destination 'platform=iOS Simulator,id=46491660-E76A-40D1-9AD8-1CEA45C1F685' -derivedDataPath .temp/TASK-260909-3hzrc3/DerivedData -parallel-testing-enabled NO -disableAutomaticPackageResolution -onlyUsePackageVersionsFromResolvedFile CODE_SIGNING_ALLOWED=NO` | 0 | 14 tests after byte-for-byte restoration from mutation. |
| `macos-build-01.log` | `xcodebuild build -project relux_sample.xcodeproj -scheme relux_sample -destination 'platform=macOS' -derivedDataPath .temp/TASK-260909-3hzrc3/DerivedData CODE_SIGNING_ALLOWED=NO` | 65 | UIKit-only rounded corner helper. |
| `macos-build-02.log` | `xcodebuild build -project relux_sample.xcodeproj -scheme relux_sample -destination 'platform=macOS' -derivedDataPath .temp/TASK-260909-3hzrc3/DerivedData CODE_SIGNING_ALLOWED=NO` | 65 | iOS-only navigation APIs. |
| `macos-build-03.log` | `xcodebuild build -project relux_sample.xcodeproj -scheme relux_sample -destination 'platform=macOS' -derivedDataPath .temp/TASK-260909-3hzrc3/DerivedData CODE_SIGNING_ALLOWED=NO` | 65 | Remaining navigation modifier in Details. |
| `macos-build-04.log` | `xcodebuild build -project relux_sample.xcodeproj -scheme relux_sample -destination 'platform=macOS' -derivedDataPath .temp/TASK-260909-3hzrc3/DerivedData CODE_SIGNING_ALLOWED=NO` | 0 | macOS 14 deployment target app builds. |
| `authui-macos-01.log` | `swift build --package-path Packages/AuthUI` | 1 | iOS-only navigation modifier. |
| `authui-macos-02.log` | `swift build --package-path Packages/AuthUI` | 0 | Standalone macOS package compiles. |
| `authui-final-03.log` | `swift build --package-path Packages/AuthUI --force-resolved-versions` | 0 | Locked standalone macOS package compiles. |
| `auth-schemes-01.log` | `xcodebuild -list -json -scheme Auth -workspace relux_sample.xcodeproj/project.xcworkspace` | 65 | Discovery attempt: workspace has no Auth scheme; used package-directory scheme instead. |
| `auth-schemes-02.log` | `(cd Packages/Auth && xcodebuild -list -json)` | 0 | Discovered Auth-Package scheme. |
| `auth-ios-01.log` | `(cd Packages/Auth && xcodebuild test -scheme Auth-Package -destination 'platform=iOS Simulator,id=46491660-E76A-40D1-9AD8-1CEA45C1F685' -derivedDataPath ../../.temp/TASK-260909-3hzrc3/AuthDerivedData -parallel-testing-enabled NO CODE_SIGNING_ALLOWED=NO)` | 0 | 6 Auth tests on iOS. |
| `auth-ios-final-02.log` | `(cd Packages/Auth && xcodebuild test -scheme Auth-Package -destination 'platform=iOS Simulator,id=46491660-E76A-40D1-9AD8-1CEA45C1F685' -derivedDataPath ../../.temp/TASK-260909-3hzrc3/AuthDerivedData -parallel-testing-enabled NO -disableAutomaticPackageResolution -onlyUsePackageVersionsFromResolvedFile CODE_SIGNING_ALLOWED=NO)` | 0 | 7 Auth tests on iOS, lock enforcement enabled. |
| `mutant-auth-01.log` | `swift test --package-path Packages/Auth --filter authorizationFalseNeverRoutesToMain` | 1 | Expected red narrowing mutant: false success admitted, service errors still refuse. |
| `mutant-notes-01.log` | `xcodebuild test -project relux_sample.xcodeproj -scheme relux_sample -destination 'platform=iOS Simulator,id=46491660-E76A-40D1-9AD8-1CEA45C1F685' -derivedDataPath .temp/TASK-260909-3hzrc3/DerivedData -parallel-testing-enabled NO -only-testing:relux_sampleTests/NotesTests/Business/Saga CODE_SIGNING_ALLOWED=NO` | 65 | Expected red narrowing mutant: only obtainFailed returns success; 6 behavioral tests executed. |
| `infrastructure-resolve-01.log` | `swift package --package-path Packages/TestInfrastructure resolve` | 0 | Standalone TestInfrastructure lock generated. |
| `locked-resolve-01.log` | `xcodebuild -resolvePackageDependencies -project relux_sample.xcodeproj -scheme relux_sample -disableAutomaticPackageResolution -onlyUsePackageVersionsFromResolvedFile` | 0 | All 5 external package revisions resolved; all 4 lockfile hashes unchanged. |
| `diff-check-final-02.log` | `git diff --check` | 0 | Patch whitespace; no repository-specific linter configuration exists. |

No source-text gate was added; its special mutation requirement is not applicable. 2 of 2 behavioral narrowing mutants were killed, with no survivors. 1 of 3 AC rows is driven by named behavioral tests; the other 2 rows use actual resolver and cited manual-audit evidence. All 3 rows have appropriate validation. Physical authentication and oldest supported runtime execution remain stated bounds. No screenshots or UI redesign were performed.

## Architecture audit and logbook

# Dependency and Architecture Audit

Task: TASK-260909-3hzrc3 (`refresh-dependencies-and-patterns`), 2026-09-09.
Baseline: `815a681105ed40c9846ac62c7c123c1250c1eb84`; the Story worktree was 0 commits behind local main. Parent verified this was current origin/main before creating the worktree. This producer leaves the candidate uncommitted for review.

## Verified dependency graph

Queried `git ls-remote --tags` for all five repositories, selected the highest stable semantic version (excluding prerelease/suffixed tags), cloned each exact tag, and inspected its manifest and implementation. The revisions below are peeled commit IDs, not annotated tag object IDs. Web release-page fetches were inconclusive; release claims here mean verified stable Git tags, not GitHub release-page metadata.

| Dependency | Previous requirement | Selected stable tag | Exact revision | Verified minimum / tools |
| --- | --- | --- | --- | --- |
| [swift-relux](https://github.com/relux-works/swift-relux/blob/483a0f2b6c97721ecb651516e9db9fb83c90cd69/Package.swift) | 9.0.0..<10 | 9.2.0 | `483a0f2b6c97721ecb651516e9db9fb83c90cd69` | iOS 13, macOS 10.15; Swift 6.0 |
| [swiftui-relux](https://github.com/relux-works/swiftui-relux/blob/ac791a9a3f84c2db0b0f874622728a7efff37e01/Package.swift) | 8.0.0..<9 | 9.0.0 | `ac791a9a3f84c2db0b0f874622728a7efff37e01` | iOS 16, macOS 13; Swift 6.0 |
| [swiftui-reluxrouter](https://github.com/relux-works/swiftui-reluxrouter/blob/cb80d2b5422a2329701d6e450815ba565b396b6d/Package.swift) | transitive; baseline resolved 11.0.3 | 12.1.0 | `cb80d2b5422a2329701d6e450815ba565b396b6d` | iOS 16, macOS 13; Swift 6.0 |
| [swift-ioc](https://github.com/relux-works/swift-ioc/blob/95dccf4b0b97c27e7e9ef41a45c1ccfbc26507dd/Package.swift) | 1.0.1..<2 | 1.0.3 | `95dccf4b0b97c27e7e9ef41a45c1ccfbc26507dd` | iOS 13, macOS 10.15; Swift 6.0 |
| [swift-log](https://github.com/apple/swift-log/blob/9c6fb14227f55d8f711ce3847dc2f419fb0ecacb/Package.swift) | 1.6.3..<2 | 1.15.1 | `9c6fb14227f55d8f711ce3847dc2f419fb0ecacb` | No platform floor in manifest; Swift 6.2 |

SwiftUIRelux 9.0.0 requires Relux >=9.2.0 and Router >=12.1.0 within their current major versions; Router requires Relux >=9.2.0. Relux, SwiftIoC, and swift-log have no external package dependencies at these tags. These five repositories are the entire external graph; the three local packages are Auth, AuthUI, and TestInfrastructure. There is no HttpClient dependency: the root manifest described nonexistent `Sources` and `TestsSupport` directories and was accidental debris.

Direct requirements are now exact in the local manifests and Xcode project. Four checked-in lockfiles cover the app and each independently resolvable package. Router's transitive revision is fixed by those lockfiles. Re-resolution with Xcode's `-onlyUsePackageVersionsFromResolvedFile` and `-disableAutomaticPackageResolution` succeeded; all 4 of 4 lockfile SHA-256 values remained unchanged. SwiftPM validation uses `--force-resolved-versions`. This demonstrates resolution at the audited revisions; it does not promise continued network availability or immutable upstream tags without the locks.

## Contracts verified from implementation

- **Module ownership:** [Relux.swift](https://github.com/relux-works/swift-relux/blob/483a0f2b6c97721ecb651516e9db9fb83c90cd69/Sources/Relux/Relux/Relux.swift) recursively retains dependencies and connects each module once by `moduleKey`. [Module](https://github.com/relux-works/swift-relux/blob/483a0f2b6c97721ecb651516e9db9fb83c90cd69/Sources/Relux/Relux/Relux+Module/Relux+Module.swift) defaults the key to concrete type identity, not instance identity. Unregister releases owners and cleans up disconnected state. The app registers its actual modules; SessionOrchestration and DataOrchestration packages mentioned in the old guide do not exist.
- **State isolation:** [State protocols](https://github.com/relux-works/swift-relux/blob/483a0f2b6c97721ecb651516e9db9fb83c90cd69/Sources/Relux/Relux/Relux+Store/Relux+State.swift) make UIState and HybridState MainActor-isolated. BusinessState requires Sendable reference semantics and async reduction/cleanup; it does not itself require an actor. Auth uses an observable HybridState; Notes uses an actor BusinessState and a MainActor ObservableObject projection. The Auth registered-module test exercises dispatch, reduction, unregister, and cleanup together.
- **Saga versus Flow:** [Saga](https://github.com/relux-works/swift-relux/blob/483a0f2b6c97721ecb651516e9db9fb83c90cd69/Sources/Relux/Relux/Relux+Saga/Relux+Saga.swift) is an Actor with `apply` returning Void; [Flow](https://github.com/relux-works/swift-relux/blob/483a0f2b6c97721ecb651516e9db9fb83c90cd69/Sources/Relux/Relux/Relux+Saga/Relux+Flow.swift) returns ActionResult and bridges to the Saga signature. [Dispatcher](https://github.com/relux-works/swift-relux/blob/483a0f2b6c97721ecb651516e9db9fb83c90cd69/Sources/Relux/Relux/Relux+Dispatcher/Relux+Dispatcher.swift) awaits subscribers and logs outcomes; serial actions do not imply serial subscribers. A handled/logged failure is still a failed operation.
- **DI lifecycles:** [IoC.swift](https://github.com/relux-works/swift-ioc/blob/95dccf4b0b97c27e7e9ef41a45c1ccfbc26507dd/Sources/IoC.swift) has distinct sync and async registrations. Sync access to an async resolver traps; `getAsync` can use either map. The app keeps async module resolution and now passes the registered RootSaga into Relux instead of creating an unrelated instance. Notes resolves its default dispatcher only when none was injected.
- **UI boundaries:** [View](https://github.com/relux-works/swiftui-relux/blob/ac791a9a3f84c2db0b0f874622728a7efff37e01/Sources/Protocols/Relux+UI+View.swift) is Equatable with equality based on props; [ViewCallback](https://github.com/relux-works/swiftui-relux/blob/ac791a9a3f84c2db0b0f874622728a7efff37e01/Sources/Relux+UI+ViewCallback.swift) equality is call-site identity, not captured-value equality. Keep model-changing values in props, dispatch in containers, and edits local until callbacks commit them. [Resolver](https://github.com/relux-works/swiftui-relux/blob/ac791a9a3f84c2db0b0f874622728a7efff37e01/Sources/View+ReluxResolver.swift) provides both the Relux environment value and observable state injection.
- **Navigation:** [ProjectingRouter](https://github.com/relux-works/swiftui-reluxrouter/blob/cb80d2b5422a2329701d6e450815ba565b396b6d/SDK/Sources/Routers/ProjectedRouter/Relux+Navigation+ProjectingRouter.swift) remains ObservableObject with a mutable native NavigationPath. The app's native NavigationStack binding is the upstream supported system-navigation boundary. Path projection uses upstream reflection; this audit does not claim a stable Apple serialization format or exhaustive navigation coverage.
- **Authentication boundary:** AuthServiceInt now exposes only domain outcomes; LocalAuthentication and LAContext stay in AuthServiceImpl. The saga accepts only `.success(true)`. `.success(false)` emits `authenticationRejected`; service errors emit failure without main navigation. The policy remains `.deviceOwnerAuthentication`, which permits system credential fallback: the existing “biometry” names do not imply biometric-only security. Physical authentication behavior is outside the automated fixture's bound.

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
