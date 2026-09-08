# Relux SwiftUI Sample

[![Swift 6.2+](https://img.shields.io/badge/Swift-6.2+-red?logo=swift)](https://swift.org/download/)
[![Platform](https://img.shields.io/badge/platform-iOS%2017%2B%20%7C%20macOS%2014%2B-blue)]()

Modular, async-first [Relux architecture for SwiftUI](https://github.com/relux-works/swift-relux). Auth is split into domain and UI packages; Notes remains an app module to demonstrate scaling from MVP to large apps while keeping boundaries clear.

Read this doc then **continue at:** [`PROJECT_GUIDE.md`](PROJECT_GUIDE.md) for workspace layout, patterns, and conventions.

---

## What's Inside

| Concept | Description |
|---------|-------------|
| **Unidirectional data flow** | Relux: Redux/Flux-inspired, Swift Concurrency-native, no functional purism |
| **Strict modularization** | Models, interfaces, implementations, UI, test-support as separate products within domain boundaries |
| **Horizontal dependencies** | Interface/Implementation split flattens dependency graph; optimizaed isolated recompilation (fast incremental builds) |
| **Domain side effects** | Sagas and Flows handle async operations within a domain (API calls, persistence, etc.) |
| **Cross-domain coordination** | Orchestrator sagas handle domain-to-domain communication |
| **Service-oriented architecture** | Services encapsulated within domain modules; manage API, networking, persistence behind protocols |
| **Layered testing** | Saga, reducer, service tested in isolation; shared test infrastructure |
| **Swift 6 concurrency** | Actor-isolation, strict sendability, structured async throughout |
| **Simpe Async-first DI** | [SwiftIoC](https://github.com/relux-works/swift-ioc) provides async module resolution, async app entry points; implementations swappable at registration |

---

## Architecture Snapshot
```
<Domain>Models        Pure data types, no dependencies
<Domain>ReluxInt      Actions, effects, state/router protocols
<Domain>ServiceInt    Service protocols
<Domain>ServiceImpl   Concrete service implementations
<Domain>ReluxImpl     State, reducer, saga, module wiring
<Domain>TestSupport   Mocks, stubs for testing
<Domain>UI            SwiftUI views (imports interfaces only)
```

**IoC wiring:** SwiftIoC registers routers, services, modules. Swap implementations by changing registration only.

---

## Quick Start

Use Xcode 26 or newer with Swift 6.2+ (required by swift-log 1.15.1).
Open `relux_sample.xcodeproj`, select `relux_sample`, and choose an iOS simulator.
The app supports iOS 17+ and macOS 14+. There is no root Swift package; package commands must specify a package directory.

See [ArchitectureAudit.md](Docs/ArchitectureAudit.md) for pinned revisions, verified contracts, regression evidence, and validation bounds.

## Tools and Validation

| Tool | Purpose | Command / entry point | Outputs |
| --- | --- | --- | --- |
| Xcode / xcodebuild | Resolve and build the iOS app | `xcodebuild build -project relux_sample.xcodeproj -scheme relux_sample -destination 'generic/platform=iOS Simulator' -derivedDataPath .temp/DerivedData -disableAutomaticPackageResolution -onlyUsePackageVersionsFromResolvedFile CODE_SIGNING_ALLOWED=NO` | `.temp/DerivedData`, Xcode configured build products |
| xcrun simctl | Find an installed test destination | `xcrun simctl list devices available` | Terminal |
| xcodebuild | Existing Notes Swift Testing suite | `xcodebuild test -project relux_sample.xcodeproj -scheme relux_sample -destination 'platform=iOS Simulator,name=iPhone 17' -derivedDataPath .temp/DerivedData -parallel-testing-enabled NO -disableAutomaticPackageResolution -onlyUsePackageVersionsFromResolvedFile CODE_SIGNING_ALLOWED=NO` | `.temp/DerivedData/Logs/Test` |
| SwiftPM | Auth Swift Testing suite on macOS | `swift test --package-path Packages/Auth --force-resolved-versions` | `Packages/Auth/.build` |
| xcodebuild | Auth package tests on iOS | From `Packages/Auth`: `xcodebuild test -scheme Auth-Package -destination 'platform=iOS Simulator,name=iPhone 17' -derivedDataPath ../../.temp/AuthDerivedData -parallel-testing-enabled NO CODE_SIGNING_ALLOWED=NO` | `.temp/AuthDerivedData` |
| SwiftPM | Standalone UI package compilation | `swift build --package-path Packages/AuthUI --force-resolved-versions` | `Packages/AuthUI/.build` |
| Git | Patch whitespace validation | `git diff --check` | Terminal; no separate lint configuration is installed |
| task-board | Task evidence and producer handoff | `task-board resource add TASK-ID /path/to/artifact --type outcome --name TASK-ID_results.md`; `task-board handoff TASK-ID --role developer` | Authoritative board resources |

Use a simulator name installed on your host. Dependency updates must update exact manifest/project requirements and the checked-in `Package.resolved` files together. Tests use Swift Testing; the Notes suite retains its existing app-hosted target, while Auth tests live in the Auth package. Store temporary logs and audit clones under `.temp/`.

---

## Documentation

| Document | Purpose |
|----------|---------|
| [`PROJECT_GUIDE.md`](./PROJECT_GUIDE.md) | Entry point: layout, conventions, setup |
| [`RELUX_MODULAR.md`](./Docs/Patterns/RELUX_MODULAR.md) | Domain decomposition pattern |
| [`RELUX_ORCHESTRATION.md`](./Docs/Patterns/RELUX_ORCHESTRATION.md) | Cross-domain coordination |
| [`RELUX_FLOW_VS_SAGA.md`](./Docs/Patterns/RELUX_FLOW_VS_SAGA.md) | When to return results vs fire-and-forget |
| [`TESTING_STRATEGY.md`](./Docs/Patterns/TESTING_STRATEGY.md) | Discrete layer testing approach |
| [`TEST_INFRASTRUCTURE.md`](./Docs/Patterns/TEST_INFRASTRUCTURE.md) | Shared test utilities |
| [`DOMAIN_TEST_SUPPORT.md`](./Docs/Patterns/DOMAIN_TEST_SUPPORT.md) | Per-domain mocks and stubs |

---

## Testing

- **Shared infrastructure:** `Packages/TestInfrastructure`: Relux logger extensions, async helpers, common mocks
- **Domain support:** `<Domain>TestSupport`: domain-specific mocks/stubs
- **Strategy:** Test saga, reducer, service in isolation; optional smoke tests for wiring

---

## Maintainers

- Alexis Grigorev
- Ivan Oparin
- Artem Grishchenko

## The Relux stack

This package is part of the Relux stack: the
[Relux](https://github.com/relux-works/swift-relux) unidirectional data-flow
architecture for Swift 6, a family of modules around it, and agent-ready testing
tools. The stack is how we build MVPs fast on agentic rails and then scale them into
enterprise-grade apps: Tuist workspaces, strict modularization, and a UDF architecture
proven in production for years. Browse the full picture in the
[Relux Works open-source catalog](https://relux.works/en/open-source/).

<!-- relux-ecosystem:start -->

## About Relux Works

This project is part of the open-source ecosystem of
[Relux Works](https://relux.works), an AI-native software development studio.
We build fixed-price MVPs, rescue vibe-coded apps, run local AI inference, and
train teams to work with coding agents. Much of the infrastructure behind that
work is open source.

- Full catalog: [relux.works/en/open-source](https://relux.works/en/open-source/)
- Agentic enablement: [agent harnesses & team training](https://relux.works/en/agentic-enablement/)
- Hire us the agent-native way: point your assistant at `https://api.relux.works/mcp`
- Contact: ivan@relux.works

<!-- relux-ecosystem:end -->
