# TASK-260909-2p9bt6 — document-architecture-diagrams

Ready for review. Documentation-only candidate remains uncommitted at baseline `a85ed27e92ee73dac35c28480bdf97d3fdfafbd6`; initial working tree was clean, HEAD..main count was 0. Parent owns integration and hosted delivery.

## Changes

- Three focused PlantUML sources and viewable SVG assets: Auth production target dependencies, Notes save UDF, logout orchestration. diagrams/README.md embeds SVGs and links implementation anchors and rendering commands.
- Four concise optional exercises: duplicate, persistence, session-safe cleanup, headless CLI. Rechecked accepted outline paths against this baseline.
- Reconciled README, Russian pointer, PROJECT_GUIDE and all six pattern guides. Replaced nonexistent example APIs/packages with actual source/test links; fixed service factory direction, product linkage, test locations and asynchronous projection/subscriber boundaries.
- Updated .spec/refresh-sample.md to the current delivery and user testing preference. Corrected the audit: root TestsSupport exists; Sources does not. Preserved pinned source citations and moved historical run bookkeeping into Docs/History/DependencyAuditEvidence.md.
- No app code, tests, manifests, locks or Xcode project changes. SVGs are explicitly requested documentation assets.

## Verification performed by this developer

Commands were standalone processes with stdout/stderr redirected to task-local logs; no tee or pipelines hid gate status. Evidence archive includes logs, diagram previews, SVGs and the task-local link checker. Working directory was the managed Story worktree. Paths below omit `.temp/TASK-260909-2p9bt6/` for logs.

| Command | Real exit | Evidence and bound |
| --- | ---: | --- |
| `plantuml -version` | 0 | plantuml-version.log; PlantUML 1.2026.6 |
| `dot -V` | 0 | graphviz-version.log |
| `xcodebuild -version` | 0 | xcode-version.log; readiness only |
| `xcrun simctl list devices available` | 0 | simulators.log; read-only destination inventory, not runtime validation |
| `plantuml -failfast2 -tpng -o "$PWD/.temp/diagrams" diagrams/plantuml/component/*.puml diagrams/plantuml/sequence/*.puml` (first) | 200 | render-01.log; actual failure from unescaped newlines, not an expected passing gate |
| `plantuml -checkonly diagrams/plantuml/component/*.puml diagrams/plantuml/sequence/*.puml` | 200 | render-diagnostic-01.log; same source defect |
| Same PNG render (corrected; then refined projection) | 0 / 0 | render-02.log and render-03.log; 3/3 retained sources rendered |
| `plantuml -failfast2 -tsvg -o "$PWD/diagrams/rendered" diagrams/plantuml/component/*.puml diagrams/plantuml/sequence/*.puml` | 0 | svg-01.log; 3/3 SVG assets |
| `python3 .temp/TASK-260909-2p9bt6/check-docs.py` (first) | 1 | links-01.log; ran too early while SVG export was writing, XML parse failure; rerun after exporter exit |
| Same link/XML check (after export; after README wording edit) | 0 / 0 | links-02.log / links-03.log; 108/108 local links across 14 docs, heading anchors, balanced fences, 3 SVG XML parses |
| `git diff --check` (two runs) | 0 / 0 | whitespace-01.log / whitespace-02.log |
| `xcodebuild build -project relux_sample.xcodeproj -scheme relux_sample -destination 'generic/platform=iOS Simulator' -derivedDataPath .temp/DerivedData -disableAutomaticPackageResolution -onlyUsePackageVersionsFromResolvedFile CODE_SIGNING_ALLOWED=NO` | 75 | build-01.log; interrupted immediately after reading the post-launch no-build directive; NOT compiler success evidence |

The initial optional skill-directory discovery and absent `.specs` lookup returned exit 2 (missing optional paths), not passing validation. The available skills were read from the supplied installed paths; actual spec is `.spec/refresh-sample.md`.

## Visual and source review

Inspected 3/3 PNG previews directly. Auth dependencies: readable labels, no clipping; all 11 local production-target dependency edges correspond to Auth/AuthUI manifests, external and test edges explicitly omitted. Notes save: success/failure branches legible; scheduled projection and operation result shown in separate parallel branches, with List.Container consuming projected state. Logout: clear two-subscriber parallel block; store cleanup is distinct from provider erasure and does not attest ordering. Re-rendered and re-inspected Notes after correcting the projection destination. SVGs use the same sources and export successfully; XML parsing validates structure, while PNG inspection establishes layout evidence.

Source anchors reviewed: package manifests; app IoC and SampleApp saga/module; Auth saga/module/state; Notes module, flow, service, provider, reducer, UI projection, Create.Container; Account logout and AuthUI logout task; actual Auth and Notes tests and helper inventories. No new upstream release claims or external URL availability checks were made; pinned audit citations were retained.

## Logbook / anomalies / bounds

- Post-launch final-docs-scope.md and cooperative directives narrow the task to three concise diagrams, visible SVGs, no app code or full build/tests. Build was started before that clarification was read and interrupted with exit 75. No behavioral tests or UI tests were executed; previous audit tests remain explicitly historical. No successful compile, app screenshots or runtime validation is claimed for this documentation candidate.
- Root TestsSupport contains PublishedWSClientMock.swift, WSClientMock.swift and RpcAsyncClientMock.swift. The previous audit wording claiming this directory was nonexistent was inaccurate and is corrected.
- ReluxImpl receives Auth's service factory rather than importing ServiceImpl. Notes UI projection is scheduled through Combine; dispatch success is not a screen-render barrier. Logout subscribers are not ordered by registration, and store cleanup does not erase provider data. These teaching boundaries are preserved throughout the guide.
- No product behavior or validation/authorization gate was changed; no mutation tests apply. Documentation correspondence is manual source review, not a behavioral test attestation. The local-link check excludes external URLs and does not prove prose truth.
- No logbook-specific CLI or repository logbook is present; this attached logbook and board note persist the findings. No unresolved product decision blocks the documentation handoff; exercise decisions are explicitly future work.
