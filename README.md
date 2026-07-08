# Relux SwiftUI Sample

[![Swift 6.0+](https://img.shields.io/badge/Swift-6.0+-red?logo=swift)](https://swift.org/download/)
[![Platform](https://img.shields.io/badge/platform-iOS%2017%2B%20%7C%20macOS%2014%2B-blue)]()

Modular, async-first [Relux architecture for SwiftUI](https://github.com/relux-works/swift-relux). Split into small domain packages (Auth, Notes) to demonstrate scaling from MVP to large apps while keeping builds fast and boundaries clear.

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
```bash
# Clone
git clone <repo-url>
cd relux-sample

# Open in Xcode
open relux_sample.xcodeproj

# Build & run
# Select relux_sample scheme → Run (Cmd+R)

# Run tests
# Product → Test (Cmd+U)
```

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
