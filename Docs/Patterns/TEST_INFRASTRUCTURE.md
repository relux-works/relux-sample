# Shared test infrastructure

[Packages/TestInfrastructure](../../Packages/TestInfrastructure/Package.swift) provides the TestInfrastructure library. It is a helper dependency, not a runnable root package or a substitute for domain tests.

| Existing source | Purpose |
| --- | --- |
| [ReluxTestingExtensions.swift](../../Packages/TestInfrastructure/Sources/TestInfrastructure/Helpers/ReluxTestingExtensions.swift) | Logger action/effect lookup and dispatch assertions |
| [AsyncTestHelpers.swift](../../Packages/TestInfrastructure/Sources/TestInfrastructure/Helpers/AsyncTestHelpers.swift) | `withTimeout(seconds:operation:)` and TimeoutError |
| [StubError.swift](../../Packages/TestInfrastructure/Sources/TestInfrastructure/Stubs/StubError.swift) | Shared test error |
| [JSONFixtures.swift](../../Packages/TestInfrastructure/Sources/TestInfrastructure/Stubs/JSONFixtures.swift) | Bundle fixture loading |
| [DomainMocks](../../Packages/TestInfrastructure/Sources/TestInfrastructure/DomainMocks) | RPC and WebSocket mock utilities |

The package does not contain the formerly documented APIClientMock, NetworkSessionMock, StorageMock, `waitUntil`, or CombineTestHelpers. Notes' [CombineAsyncStream.swift](../../relux_sampleTests/Notes/Utils/CombineAsyncStream.swift) remains local to its app test target.

A timeout is cooperative: cancelling a child does not force non-cooperative work to stop. Use bounded, cancellation-aware operations and inspect actual emitted values. Logging proves dispatch observation, not successful state reduction or service persistence. Pair logger assertions with result/state checks at the relevant layer.

Run consuming suites using [README](../../README.md#tools-and-validation). Add reusable helpers only when multiple domains need the same tested contract; keep domain-specific mocks in [domain support](DOMAIN_TEST_SUPPORT.md).
