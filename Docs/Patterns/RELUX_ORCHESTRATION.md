# Relux orchestration

Cross-domain coordination lives at the composition boundary. [App IoC](../../relux_sample/IoC/IoC.swift) registers ErrorHandling, Navigation, Auth and Notes with one Store and RootSaga. It supplies Auth's service and injects `flow.authenticate()` into Notes as an async Boolean callback. Notes does not import Auth implementations, and Auth knows nothing about note IDs or navigation.

## Await the required outcome

Unlock Note dispatches a Notes effect from its container. The Notes Flow awaits service/provider work; the provider awaits the injected Auth callback before granting access to that note. There are no independent logout subscribers or global login route. See the [unlock sequence](../../diagrams/README.md) and [access lifetime](NOTE_PROTECTION.md).

The root container handles background transitions by hiding protected content and awaiting Notes relock. The provider owns revocation, while the root temporarily removes presentation content so editor drafts cannot remain visible during revocation. Inactive transitions from the system prompt are not background transitions.

## Scaling beyond the demo

Use an app-local orchestrator when multiple domain outcomes must be coordinated. Await dependencies explicitly: registration order and serial action dispatch do not establish subscriber ordering. A Saga returns Void but its async work can still be awaited. Extract a package only when ownership or reuse warrants it; do not create another domain-state store in the coordinator.
