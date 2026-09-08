# Flow versus Saga

| Contract | Flow | Saga |
| --- | --- | --- |
| `apply` result | `Relux.Flow.Result` (ActionResult) | `Void` |
| Caller gets operation success/failure | Yes | Observe domain state/actions instead |
| Async work awaited | Yes | Yes; Void does not mean detached |
| State mutation | Dispatch actions to reducers | Dispatch actions to reducers |
| Current example | Notes create/update/delete/fetch | Auth and SampleApp coordination |

## Notes: return the operation outcome

[Notes.Business.Flow](../../relux_sample/Modules/Notes/Business/Middleware/Notes+Business+Flow.swift) calls an injected service. A successful upsert dispatches `upsertNoteSuccess` and returns `.success`. Failure dispatches `upsertNoteFail` and error tracking concurrently, then returns `.failure(err)`. Logging never converts failure into success. The service rejects blank titles/content before writing to the provider.

[Create.Container](../../relux_sample/Modules/Notes/UI/Create/Notes+UI+Create+Container.swift) awaits `actions(actions: { Notes.Business.Effect.upsert(note: note) })`; success dismisses the editor, failure sets an error message while preserving its local draft. Views invoke callbacks; they do not dispatch Relux actions.

See the [upsert sequence](../../diagrams/plantuml/sequence/notes-upsert.puml). Awaiting reduction is not a guarantee that Combine's scheduled main-queue projection or SwiftUI rendering has already occurred.

## Auth: observe actions and navigation

[Auth.Business.Saga](../../Packages/Auth/Sources/AuthReluxImpl/Business/Middleware/Auth+Business+Saga.swift) accepts only `.success(true)` from `runLocalAuth`. False emits `authenticationRejected`; errors emit failure. Only true dispatches `authSucceed` and the main route. LocalAuthentication uses device-owner authentication, including system credential fallback; the “biometry” names do not promise biometric-only authentication.

The caller does not use a returned domain result to navigate: the saga requests routing through its injected interface. Thus navigation alone does not dictate Flow versus Saga. Choose based on who owns the outcome and how consumers observe it. Cross-domain event observers in this sample use Saga; see [orchestration](RELUX_ORCHESTRATION.md).

## Validate both sides

Assert returned Flow results as well as actions and state. For Auth, exercise true, false and error service outcomes through registered module dispatch. Existing examples are linked in [Testing Strategy](TESTING_STRATEGY.md); a logged success-path action is not sufficient evidence of failure handling.
