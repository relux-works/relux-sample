# Relux orchestration

Cross-domain coordination lives at the composition boundary. In this sample, [SampleApp.Business.Saga](../../relux_sample/Modules/App/Business/SampleApp+Business+Saga.swift) observes `Auth.Business.Effect.runLogoutFlow` and calls `store.cleanup(exclusions: [AppRouter.self])`. [SampleApp.Module](../../relux_sample/Modules/App/App+Module.swift) registers the saga and no states.

See the [logout sequence](../../diagrams/plantuml/sequence/logout-orchestration.puml).

## Actual entry point

Account's container dispatches `Auth.Business.Effect.logout`. Auth routes to `.logoutFlow`; that screen's container dispatches `runLogoutFlow` from its task. Two sagas observe the effect:

- Auth recreates its LocalAuthentication context, then dispatches the local-auth route and `logOutSucceed` action.
- SampleApp cleans registered store states except AppRouter.

Auth does not import Notes. The app coordinates cleanup through the store. Cleanup is not deletion of the in-memory Notes fetcher, and no late-request rejection is implemented. See the [session-safe cleanup exercise](../LearningExercises.md#3-make-logout-cleanup-session-safe).

## Ordering and ownership

Registration makes modules available; it does not establish a subscriber execution order. The actual IoC registration order is ErrorHandling, Navigation, SampleApp, Auth, then async Notes. Serial dispatch orders actions within that dispatch, not all saga subscribers of one effect. If an invariant requires cleanup before routing, make the awaited coordination explicit and test that order with a held request.

A Saga returns Void but its async work can still be awaited. Avoid interpreting “fire-and-forget” as a detached task or proof that the operation succeeded. Store state belongs to domains; coordination should not create another copy of it.

## Scaling beyond the demo

SessionOrchestration, DataOrchestration, Profile and Settings packages do not exist here. A larger app may extract a focused concern into an orchestrator that imports domain interfaces and exposes no domain state. Start with an app-local saga until separate ownership or reuse warrants a package. Test through registered dispatch and assert real state/service/routing outcomes, not only the presence of logged effects.
