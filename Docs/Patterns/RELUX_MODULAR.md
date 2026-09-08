# Relux modular architecture

Auth demonstrates six library products within [one package](../../Packages/Auth/Package.swift). Notes stays inside the app until reuse or ownership justifies extraction. Six products are a boundary example, not a minimum size for every feature.

| Auth product | Responsibility | Direct local target dependencies |
| --- | --- | --- |
| AuthModels | Namespace, data, errors | None |
| AuthReluxInt | Authentication effect and Flow contract | AuthModels |
| AuthServiceInt | Service contract | AuthModels |
| AuthServiceImpl | LocalAuthentication implementation | AuthModels, AuthServiceInt |
| AuthReluxImpl | Result-bearing Flow and module | AuthModels, AuthReluxInt, AuthServiceInt |
| AuthTestSupport | Domain test helpers | AuthModels, AuthServiceInt, AuthReluxInt |

External dependencies are explicit in the manifest: Relux and SwiftIoC for runtime wiring, TestInfrastructure for helpers. Auth has no UI package or login state. See the [dependency diagram](../../diagrams/plantuml/component/auth-dependencies.puml).

## Composition root

[App IoC](../../relux_sample/IoC/IoC.swift) imports implementation products and supplies `Auth.Module(service:)` and injects its `flow.authenticate()` through a callback into Notes. AuthReluxImpl does not import AuthServiceImpl or app navigation. Swap the service at this construction boundary.

Use target names for dependencies within a package and product dependencies across packages. Use automatic library linkage. Do not add a self-package dependency or manually embed every product: duplicate static Relux ownership caused runtime duplicate-class warnings in the [architecture audit](../ArchitectureAudit.md). TestSupport belongs to testing consumers, not the app's production dependency graph. There is no installed import-lint gate; manifests, compilation and review enforce the current boundaries.

## State sizing

Auth returns an authentication outcome without maintaining global state. Notes uses an actor BusinessState and a derived MainActor UIState with a dictionary and groups ordered by creation day. BusinessState as an upstream protocol requires Sendable reference semantics and async reduction/cleanup; using an actor is this app's choice. UIState is a projection, not a second editable domain store.

[Notes.Module](../../relux_sample/Modules/Notes/Notes+Module.swift) constructs both states, a flow, a service and an in-memory fetcher. Its current wiring is not a headless package. Extract a business-only composition when undertaking the [CLI exercise](../LearningExercises.md#4-reuse-notes-from-a-headless-cli).

## Add a boundary when it earns its cost

1. Identify independent reuse, ownership or build needs.
2. Define model and interface targets without UI or concrete service imports.
3. Implement services and reducers behind those contracts.
4. Inject implementations and router adapters from the app.
5. Add focused Swift Testing coverage and register the module before dispatching work.
6. Update the dependency diagram and dependency locks when the graph changes.
