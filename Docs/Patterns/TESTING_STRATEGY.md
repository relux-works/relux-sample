# Testing strategy

Use Swift Testing (`@Suite`, `@Test`, `#expect`, `#require`) in Swift. [README commands](../../README.md#tools-and-validation) are the maintained build/test entry points; there is no root Swift package.

## Existing suites

| Source | Entry point and assertions | Bound |
| --- | --- | --- |
| [AuthBehaviorTests](../../Packages/Auth/Tests/AuthTests/AuthBasicsTests.swift) | Registered module dispatch; authorization true/false/error and cancellation | Injected service; does not exercise physical LocalAuthentication |
| [Notes flow tests](../../relux_sampleTests/Notes/Business/Saga/NotesTests+Business+Saga+Obtain.swift) | `Flow.apply`; returned result and logged actions for success/failure (also Upsert and Delete files) | Injected service/dispatcher; not whole-app UI |
| [Notes reducer tests](../../relux_sampleTests/Notes/Business/State/NotesTests+Business+State+Upsert.swift) | Real action reduction and domain state | No provider or routing integration |
| [Notes UIState tests](../../relux_sampleTests/Notes/UI/State/NotesTests+UI+State.swift) | Business-to-UI projection | Does not prove rendered frames |
| [NotesNativeWorkflowTests](../../relux_sampleTests/Notes/NotesNativeWorkflowTests.swift) | Draft validation and identity, real in-memory service CRUD, blank-input rejection through Flow, search mapping and save-button props | Does not tap the native UI or prove persistence |

Auth tests live in a package target. Notes retains the app-hosted `relux_sampleTests` target; its `Business/Saga` directory tests a Flow. Prefer package test targets for newly extracted business code without pretending the existing hosted suite has moved.

## Add tests at the changed boundary

- Flow: inject a service; assert both operation result and all dispatched success/failure actions. Concurrent error tracking must not hide failure.
- Reducer: pass real actions; assert resulting values and preservation on failed mutations. Use an exhaustive switch over the domain action enum.
- Service/provider: verify conversion and error mapping. For durable storage, use a temporary real store and recreate it to verify persistence. These durability tests are proposed, not present.
- Orchestration: drive registered dispatch; assert state, provider policy and routing. Hold an authentication request across relock and verify it cannot restore a grant.
- UI projection: observe derived values with a bounded wait; do not assume dispatch return means Combine delivery has run.
- Wiring: register the real module, dispatch via its production dispatcher, and inspect the resulting state. Use AuthBehaviorTests as the executable example instead of inventing Store registration APIs.

Mocks should fail on unintended calls and use actor isolation or another explicit synchronization policy when mutable. `@unchecked Sendable` alone is not synchronization. See [domain support](DOMAIN_TEST_SUPPORT.md) and [shared infrastructure](TEST_INFRASTRUCTURE.md).

## Evidence boundaries

A passing test proves only the path it drives. Include negative cases for validation or authorization, such as blank text or `.success(false)`. For a gate change, narrow the gate to admit one forbidden class and name the test that fails; report surviving mutations and their limits. Documentation-only changes need source/link checks and rendering, not new behavior tests that mirror prose. Keep command exit codes and raw logs in `.temp/` and attach task evidence before handoff.
