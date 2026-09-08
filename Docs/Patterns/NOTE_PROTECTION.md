# Per-note device-owner authentication

Notes opens without authentication. The Notes toolbar pushes Settings, then Account information through [app routes](../../relux_sample/Modules/App/UI/Root/App+UI+Root+Router.swift). There is no app-wide sign-in or logout.

## Ownership and entry point

[Details.Container](../../relux_sample/Modules/Notes/UI/Details/Notes+UI+Details+Container.swift) wraps Lock Note, Unlock Note, Relock and Remove Lock in callbacks that dispatch Notes effects. Lock Note protects and immediately locks an ordinary note without prompting. Unlock Note invokes the [Notes Flow](../../relux_sample/Modules/Notes/Business/Middleware/Notes+Business+Flow.swift), [service](../../relux_sample/Modules/Notes/Business/Middleware/Notes+Business+Service.swift) and [provider](../../relux_sample/Modules/Notes/Data/Api/Notes+Data+Api+Fetcher.swift). App IoC injects the reusable Auth Flow; the provider alone owns protection metadata and per-note grants.

The [Auth service](../../Packages/Auth/Sources/AuthServiceImpl/Auth+Business+Service.swift) creates and invalidates a fresh LAContext for each request. It evaluates `deviceOwnerAuthentication`: system biometry with device passcode or macOS password fallback, not an app-defined PIN or account identity. False, cancellation, unavailable policy and evaluation errors do not authorize access.

## Visibility and lifetime

Titles remain visible and searchable. Locked snapshots redact bodies before reaching business/UI state, so previews, body search and details cannot display that content. The provider rejects edits, deletion and removing protection while locked. Existing provider metadata wins over editor-supplied protection flags.

A grant applies to one note and survives navigation and refresh until relock or background revocation; there is no timer. Remove Lock requires access and revokes the grant while making the note ordinary. Deletion also revokes access. Notes, protection and grants reset on process restart.

[The root](../../relux_sample/Modules/App/UI/Root/App+UI+Root+Container.swift) hides protected content immediately on background, removes presentation content while revocation is pending, and dispatches relock for all notes. Inactive system-prompt transitions do not relock. [The editor](../../relux_sample/Modules/Notes/UI/Edit/Notes+UI+Edit+Container.swift) resolves the current note by ID, refuses locked content and dismisses on background; background destroys local drafts.

Each revocation advances the provider's per-note generation. An authentication result grants access only if the generation still matches, the task is not cancelled and the note remains protected. A later unlock supersedes an earlier request. Provider snapshots have increasing revisions; [the reducer](../../relux_sample/Modules/Notes/Business/Notes+Business+State+Reducer.swift) rejects older snapshots. These are separate guards against late authentication and stale projection input.

This is **in-memory access control, not at-rest encryption**. Plaintext remains inside the provider, and no durable storage or backend account isolation is implemented. See the [rendered unlock sequence](../../diagrams/README.md) and [optional extensions](../LearningExercises.md).
