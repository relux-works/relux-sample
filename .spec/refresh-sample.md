# Relux sample delivery scope

## Implemented baseline

Dependency and architecture repairs retain iOS 17/macOS 14 deployment targets with Xcode 26+ / Swift 6.2+. Auth is packaged behind interfaces; Notes remains an app-local in-memory domain. The accepted native Notes demo includes create/edit/delete, search, draft validation and failure feedback. Current documentation baseline: `a85ed27e92ee73dac35c28480bdf97d3fdfafbd6` (app PR #2).

## Learning materials: TASK-260909-2p9bt6

Publish the accepted TASK-260909-3kd1i7 outline as a concise optional exercises guide. Retain three focused diagram sources in `diagrams/` covering module dependencies, Notes save UDF and logout orchestration; include viewable SVG documentation assets and render temporary previews under `.temp/`. Reconcile README, its Russian pointer, PROJECT_GUIDE and pattern docs with actual source. Preserve pinned upstream citations and separate historical audit evidence from learning prose.

Persistence, session-safe provider cleanup and a headless CLI are optional future exercises, not implemented behavior. No functional app changes, generated Xcode project artifacts, or new dependencies belong to this documentation task.

## Validation and delivery boundary

The user stopped expensive UI testing and authorized blind best-effort app delivery. Do not run app UI tests, screenshots, full builds or behavioral test suites for this documentation-only scope. Validate local links, review source correspondence, render diagrams and visually inspect their previews. Report validation bounds honestly; previous app evidence is historical, not a new execution.

The developer leaves documentation uncommitted in the managed Story worktree and attaches task-scoped outcomes before handing off to review. The parent owns signed commits, hosted PR review, publication and landing.
