# Relux SwiftUI Sample

[![Swift 6.0+](https://img.shields.io/badge/Swift-6.0+-red?logo=swift)](https://swift.org/download/)

This repository demonstrates a modular, async-first Relux architecture for SwiftUI. It is intentionally split into small domain packages (Auth, AuthUI, TestInfrastructure, HttpClient, etc.) to show how to scale from MVP to large apps while keeping builds fast and boundaries clear.

**Must read:** start with `PROJECT_GUIDE.md` for workspace layout, schemes, and how to build/test.

## What’s inside
- **Unidirectional, async-first state** with Relux (Redux-inspired, Swift Concurrency-native).
- **Strict modularization:** models, interfaces (Int), implementations (Impl), UI, and test-support are separate products; DI wires them at runtime.
- **Dynamic-link strategy:** interface products stay dynamic; implementations are swappable via IoC without leaking imports.
- **Shared testing:** `TestInfrastructure` plus domain `*TestSupport` targets provide mocks/stubs/helpers.

## Architecture snapshot
- `*Models`: pure data.
- `*ReluxInt`: actions/effects/state/router contracts (no concretes).
- `*ServiceInt` / `*ServiceImpl`: service protocols and concrete implementations.
- `*ReluxImpl`: state, reducer, saga, module wiring; depends only on interfaces and DI.
- UI packages (e.g., AuthUI) import interfaces, not impls.
- IoC: SwiftIoC registers routers, services, and modules; swapping impls = change registration only.

## Testing
- **Shared:** `Packages/TestInfrastructure` (Relux logger helpers, timeout helper, JSON fixtures, conditional HttpClient mocks).
- **Domain:** `AuthTestSupport` (mocks/stubs for Auth). Import these in tests instead of concrete impls.

## Documentation
- Core guide: `PROJECT_GUIDE.md`.
- Patterns (docs/Patterns):
  - `RELUX_MODULAR.md`
  - `RELUX_FLOW_VS_SAGA.md`
  - `RELUX_ORCHESTRATION.md`
  - `DOMAIN_TEST_SUPPORT.md`
  - `TEST_INFRASTRUCTURE.md`
  - `TESTING_STRATEGY.md`

## License
MIT

## Maintainers
- Alexis Grigorev
- Artem Grishchenko
- Ivan Oparin
