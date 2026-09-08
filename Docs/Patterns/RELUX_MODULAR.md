# Relux Modular Architecture

Domain decomposition pattern for scalable iOS/macOS applications.

---

## Goals

- Scale from MVP to 1000+ module apps
- Fast incremental builds via isolated recompilation
- Explicit module boundaries with predictable layering
- Clear seams for implementation swapping via DI
- Repeatable pattern across all domains

---

## Package Layout

Single package, multiple library products per domain:

| Product | Contents | Dependencies |
|---------|----------|--------------|
| `<Domain>Models` | Namespace, data types, errors. No Relux. | — |
| `<Domain>ReluxInt` | Actions, effects, state/router protocols, UI page enums | Models, Relux |
| `<Domain>ServiceInt` | Service protocol(s) only | Models |
| `<Domain>ServiceImpl` | Concrete service implementation | Models, ServiceInt |
| `<Domain>ReluxImpl` | State, reducer, saga/flow, module wiring | Models, ReluxInt, ServiceInt, ServiceImpl, SwiftIoC, Relux |
| `<Domain>TestSupport` | Mocks, stubs, test helpers (static library) | Models, ReluxInt, ServiceInt, TestInfrastructure |

Use automatic library linkage. Static upstream dependencies must have one owner in the final process; see [the verified architecture audit](../ArchitectureAudit.md).

---

## Dependency Graph
```
┌─────────────────────────────────────────────────────────────────┐
│                         App Host Binary                         │
│  Links & embeds all domain products                            │
└─────────────────────────────────────────────────────────────────┘
                              │
        ┌─────────────────────┼─────────────────────┐
        ▼                     ▼                     ▼
┌───────────────┐    ┌───────────────┐    ┌───────────────┐
│<Domain>ReluxImpl│   │<Domain>ServiceImpl│ │<Domain>TestSupport│
└───────────────┘    └───────────────┘    └───────────────┘
        │                     │                     │
        ▼                     ▼                     ▼
┌───────────────┐    ┌───────────────┐    ┌───────────────┐
│<Domain>ReluxInt│    │<Domain>ServiceInt│  │TestInfrastructure│
└───────────────┘    └───────────────┘    └───────────────┘
        │                     │
        └──────────┬──────────┘
                   ▼
          ┌───────────────┐
          │ <Domain>Models │
          └───────────────┘
```

---

## Package.swift Template
```swift
// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "<Domain>",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "<Domain>Models", targets: ["<Domain>Models"]),
        .library(name: "<Domain>ReluxInt", targets: ["<Domain>ReluxInt"]),
        .library(name: "<Domain>ServiceInt", targets: ["<Domain>ServiceInt"]),
        .library(name: "<Domain>ServiceImpl", targets: ["<Domain>ServiceImpl"]),
        .library(name: "<Domain>ReluxImpl", targets: ["<Domain>ReluxImpl"]),
        .library(name: "<Domain>TestSupport", targets: ["<Domain>TestSupport"]),
    ],
    dependencies: [
        .package(url: "https://github.com/relux-works/swift-ioc.git", exact: "1.0.3"),
        .package(url: "https://github.com/relux-works/swift-relux.git", exact: "9.2.0"),
        .package(path: "../TestInfrastructure"),
    ],
    targets: [
        .target(
            name: "<Domain>Models",
            dependencies: []
        ),
        .target(
            name: "<Domain>ReluxInt",
            dependencies: [
                "<Domain>Models",
                .product(name: "Relux", package: "swift-relux"),
            ]
        ),
        .target(
            name: "<Domain>ServiceInt",
            dependencies: [
                "<Domain>Models",
            ]
        ),
        .target(
            name: "<Domain>ServiceImpl",
            dependencies: [
                "<Domain>Models",
                "<Domain>ServiceInt",
            ]
        ),
        .target(
            name: "<Domain>ReluxImpl",
            dependencies: [
                "<Domain>Models",
                "<Domain>ReluxInt",
                "<Domain>ServiceInt",
                "<Domain>ServiceImpl",
                .product(name: "SwiftIoC", package: "swift-ioc"),
                .product(name: "Relux", package: "swift-relux"),
            ]
        ),
        .target(
            name: "<Domain>TestSupport",
            dependencies: [
                "<Domain>Models",
                "<Domain>ReluxInt",
                "<Domain>ServiceInt",
                .product(name: "TestInfrastructure", package: "TestInfrastructure"),
            ]
        ),
        .testTarget(
            name: "<Domain>Tests",
            dependencies: [
                "<Domain>ReluxImpl",
                "<Domain>TestSupport",
            ]
        ),
    ]
)
```

---

## Layering Rules

| Layer | Can Import | Cannot Import |
|-------|-----------|---------------|
| UI | ReluxInt, Models | ReluxImpl, ServiceImpl |
| ReluxImpl | ReluxInt, ServiceInt, ServiceImpl, Models | UI |
| ServiceImpl | ServiceInt, Models | Relux*, UI |
| ServiceInt | Models | Everything else |
| Models | Nothing domain-specific | Everything else |

**Enforcement**: Code review, lint rules, or build-time import checks.

---

## Linking Boundaries

Use ordinary target dependencies within one package and product dependencies across packages. Keep library products automatic unless a measured deployment requirement needs dynamic linkage. Do not self-reference the package to force dynamic products: this sample reproduced duplicate Relux runtime classes when multiple Auth libraries embedded the same static upstream dependency. Xcode links the automatic products without manual Embed Frameworks entries.

---

## IoC Integration
```swift
// <Domain>ReluxImpl/<Domain>+Module.swift

extension <Domain> {
    @MainActor
    public struct Module: Relux.Module {
        private let ioc: IoC
        
        public let states: [any Relux.AnyState]
        public let sagas: [any Relux.Saga]
        
        public init(router: <Domain>.Business.IRouter) {
            self.ioc = Self.buildIoC(router: router)
            
            self.states = [
                ioc.get(by: <Domain>.Business.IState.self)!
            ]
            self.sagas = [
                ioc.get(by: <Domain>.Business.ISaga.self)!
            ]
        }
    }
}

extension <Domain>.Module {
    private static func buildIoC(router: <Domain>.Business.IRouter) -> IoC {
        let ioc = IoC(logger: IoC.Logger(enabled: false))
        
        ioc.register(<Domain>.Business.IRouter.self, lifecycle: .container) { router }
        ioc.register(<Domain>.Business.IState.self, lifecycle: .container) { <Domain>.Business.State() }
        ioc.register(<Domain>.Business.IService.self, lifecycle: .container) { <Domain>.Business.Service() }
        ioc.register(<Domain>.Business.ISaga.self, lifecycle: .container) { 
            <Domain>.Business.Saga(
                svc: ioc.get(by: <Domain>.Business.IService.self)!,
                router: ioc.get(by: <Domain>.Business.IRouter.self)!
            )
        }
        
        return ioc
    }
}
```

---

## Router Protocol Pattern

Domains define navigation needs via protocol; app provides implementation:
```swift
// <Domain>ReluxInt
extension <Domain>.Business {
    public protocol IRouter: Sendable {
        func set<Domain>Page(_ page: <Domain>.UI.Model.Page) -> any Relux.Action
        func pushMain() -> any Relux.Action
    }
}

// App provides adapter
struct <Domain>RouterAdapter: <Domain>.Business.IRouter {
    func set<Domain>Page(_ page: <Domain>.UI.Model.Page) -> any Relux.Action {
        AppRouter.Action.set([.<domain>(page: page)])
    }
    
    func pushMain() -> any Relux.Action {
        AppRouter.Action.push(.app(page: .main))
    }
}
```

---

## UI Package (Optional)

For domains with views, separate UI package:
```
<Domain>UI/
  Package.swift
  Sources/
    <Domain>UIAPI/      ← View provider protocol
    <Domain>UI/         ← Concrete views
```
```swift
// <Domain>UIAPI
public protocol <Domain>UIProviding: Sendable {
    @MainActor
    func view(for page: <Domain>.UI.Model.Page) -> AnyView
}

// <Domain>UI
public struct <Domain>UIRouter: <Domain>UIProviding {
    @MainActor
    public func view(for page: <Domain>.UI.Model.Page) -> AnyView {
        switch page {
            case .list: AnyView(<Domain>.UI.List.Container())
            case .details(let id): AnyView(<Domain>.UI.Details.Container(id: id))
        }
    }
}
```

---

## Checklist: New Domain

1. [ ] Create `<Domain>/Package.swift` with 6 products
2. [ ] Implement `<Domain>Models` — namespace, data types, errors
3. [ ] Implement `<Domain>ServiceInt` — service protocol
4. [ ] Implement `<Domain>ServiceImpl` — concrete service
5. [ ] Implement `<Domain>ReluxInt` — actions, effects, state protocol, router protocol
6. [ ] Implement `<Domain>ReluxImpl` — state, reducer, saga/flow, module
7. [ ] Implement `<Domain>TestSupport` — mocks, stubs
8. [ ] Add tests in `<Domain>Tests`
9. [ ] Register module in app `IoC.swift`
10. [ ] Create router adapter in app
11. [ ] Add to orchestrator if cross-domain coordination needed
12. [ ] Create `<Domain>UI` package if views needed

---

## Benefits

- **Smaller recompilation surface**: Model changes don't touch Relux or services
- **Clear DI seams**: Swap implementations (mock/real) via IoC
- **Repeatable**: Clone pattern for any domain
- **Agent-friendly**: Explicit boundaries prevent accidental coupling

---

## Trade-offs

| Concern | Mitigation |
|---------|------------|
| Multiple dylibs increase launch time | Monitor on device; merge impl products per domain if needed |
| Duplicate runtime classes from forced dynamic products | Use automatic linkage with ordinary target dependencies |
| Verbose imports | Optional facade product (`<Domain>Kit`) for simple consumers |
| 6 products per domain seems heavy | Start with HybridState in ReluxImpl; split when complexity grows |
