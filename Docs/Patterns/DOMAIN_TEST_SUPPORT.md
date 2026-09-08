# Domain test support

[AuthTestSupport](../../Packages/Auth/Package.swift) is the existing domain helper product. It contains a [service mock](../../Packages/Auth/Sources/AuthTestSupport/Mocks/Auth+ServiceMock.swift), [model stubs](../../Packages/Auth/Sources/AuthTestSupport/Stubs/Auth+Model+Stubs.swift), and [assertion helpers](../../Packages/Auth/Sources/AuthTestSupport/Assertions/Auth+TestHelpers.swift). It is not proof that every current test consumes those helpers: AuthBehaviorTests defines its own fixtures.

Within a package, reference targets by name (`"AuthModels"`, `"AuthServiceInt"`, `"AuthReluxInt"`). Across packages, use `.product(name: "TestInfrastructure", package: "TestInfrastructure")`. Do not introduce a `Domain-Self` package reference or force dynamic libraries for test support.

Notes is not extracted and has no NotesTestSupport product. Its mocks and stubs live under [relux_sampleTests/Notes](../../relux_sampleTests/Notes). Move them with the domain if the [headless extraction exercise](../LearningExercises.md#4-reuse-notes-from-a-headless-cli) is undertaken.

## Fixture discipline

Prefer actor-isolated mutable service fixtures for concurrent tests. The legacy Auth ServiceMock uses `@unchecked Sendable` with mutable handlers and counters; do not share it across concurrent tests or treat the annotation as a concurrency guarantee. Its `recreateLAContext` is a no-op, so use an explicit recording fixture when asserting that behavior.

Use stable IDs, dates and explicit strings when they affect assertions. Return deliberate failures for unexpected calls. Assert false authorization separately from thrown/service errors; assert Flow failure separately from logged error effects. See executable [Auth tests](../../Packages/Auth/Tests/AuthTests/AuthBasicsTests.swift) and the [testing strategy](TESTING_STRATEGY.md).
