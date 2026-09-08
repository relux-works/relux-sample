# Flow versus Saga

| Contract | Flow | Saga |
| --- | --- | --- |
| `apply` result | `Relux.Flow.Result` (ActionResult) | `Void` |
| Caller gets operation success/failure | Yes | Observe domain state/actions instead |
| Async work awaited | Yes | Yes; Void does not mean detached |
| State mutation | Dispatch actions to reducers | Dispatch actions to reducers |
| Current example | Notes operations and Auth authentication | Error tracking |

## Notes: return the operation outcome

[Notes.Business.Flow](../../relux_sample/Modules/Notes/Business/Middleware/Notes+Business+Flow.swift) calls an injected service. A successful upsert fetches a provider snapshot and dispatches `Action.snapshot`; the reducer accepts only a newer revision. The Flow returns the refresh outcome. Failure dispatches `upsertNoteFail` and error tracking concurrently, then returns `.failure(err)`. Logging never converts failure into success. The service rejects blank titles/content before writing to the provider.

[Create.Container](../../relux_sample/Modules/Notes/UI/Create/Notes+UI+Create+Container.swift) awaits `actions(actions: { Notes.Business.Effect.upsert(note: note) })`; success dismisses the editor, failure sets an error message while preserving its local draft. Views invoke callbacks; they do not dispatch Relux actions.

See the [upsert sequence](../../diagrams/plantuml/sequence/notes-upsert.puml). Awaiting reduction is not a guarantee that Combine's scheduled main-queue projection or SwiftUI rendering has already occurred.

## Auth: return a reusable authentication outcome

[Auth.Business.Flow](../../Packages/Auth/Sources/AuthReluxImpl/Business/Middleware/Auth+Business+Flow.swift) accepts only `.success(true)` from `runLocalAuth`. False becomes `authenticationRejected`; service errors and cancellation remain failures. It returns an outcome without navigation or global login actions. App IoC adapts that result to the Notes provider's authentication callback.

The provider decides whether the requested note may receive a grant after the await. See [note protection](NOTE_PROTECTION.md) and [composition](RELUX_ORCHESTRATION.md). Auth proves device-owner authentication; Notes owns access lifetime.

## Validate both sides

Assert returned Flow results as well as actions and state. For Auth, exercise true, false and error service outcomes through registered module dispatch. Existing examples are linked in [Testing Strategy](TESTING_STRATEGY.md); a logged success-path action is not sufficient evidence of failure handling.
