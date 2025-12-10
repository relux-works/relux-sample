# Relux Modular Architecture

Domain decomposition pattern for scalable iOS/macOS applications.

---

## Goals

- Scale from MVP to 1000+ module apps
- Fast incremental builds via isolated recompilation
- Explicit dynamic linkage with predictable layering
- Clear seams for implementation swapping via DI
- Repeatable pattern across all domains

---

## Package Layout

Single package, multiple dynamic products per domain:

| Product | Contents | Dependencies |
|---------|----------|--------------|
| `<Domain>Models` | Namespace, data types, errors. No Relux. | — |
| `<Domain>ReluxInt` | Actions, effects, state/router protocols, UI page enums | Models, Relux |
| `<Domain>ServiceInt` | Service protocol(s) only | Models |
| `<Domain>ServiceImpl` | Concrete service implementation | Models, ServiceInt |
| `<Domain>ReluxImpl` | State, reducer, saga/flow, module wiring | Models, ReluxInt, ServiceInt, ServiceImpl, SwiftIoC, Relux |
| `<Domain>TestSupport` | Mocks, stubs, test helpers (static library) | Models, ReluxInt, ServiceInt, TestInfrastructure |

All products except TestSupport are `type: .dynamic`.

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
        .library(name: "<Domain>Models", type: .dynamic, targets: ["<Domain>Models"]),
        .library(name: "<Domain>ReluxInt", type: .dynamic, targets: ["<Domain>ReluxInt"]),
        .library(name: "<Domain>ServiceInt", type: .dynamic, targets: ["<Domain>ServiceInt"]),
        .library(name: "<Domain>ServiceImpl", type: .dynamic, targets: ["<Domain>ServiceImpl"]),
        .library(name: "<Domain>ReluxImpl", type: .dynamic, targets: ["<Domain>ReluxImpl"]),
        .library(name: "<Domain>TestSupport", targets: ["<Domain>TestSupport"]),
    ],
    dependencies: [
        // Self-reference forces dynamic linkage within package
        .package(name: "<Domain>-Self", path: "."),
        .package(url: "https://github.com/ivalx1s/swift-ioc.git", from: "1.0.1"),
        .package(url: "https://github.com/ivalx1s/darwin-relux.git", from: "8.4.0"),
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
                .product(name: "<Domain>Models", package: "<Domain>-Self"),
                .product(name: "Relux", package: "darwin-relux"),
            ]
        ),
        .target(
            name: "<Domain>ServiceInt",
            dependencies: [
                .product(name: "<Domain>Models", package: "<Domain>-Self"),
            ]
        ),
        .target(
            name: "<Domain>ServiceImpl",
            dependencies: [
                .product(name: "<Domain>Models", package: "<Domain>-Self"),
                .product(name: "<Domain>ServiceInt", package: "<Domain>-Self"),
            ]
        ),
        .target(
            name: "<Domain>ReluxImpl",
            dependencies: [
                .product(name: "<Domain>Models", package: "<Domain>-Self"),
                .product(name: "<Domain>ReluxInt", package: "<Domain>-Self"),
                .product(name: "<Domain>ServiceInt", package: "<Domain>-Self"),
                .product(name: "<Domain>ServiceImpl", package: "<Domain>-Self"),
                .product(name: "SwiftIoC", package: "swift-ioc"),
                .product(name: "Relux", package: "darwin-relux"),
            ]
        ),
        .target(
            name: "<Domain>TestSupport",
            dependencies: [
                .product(name: "<Domain>Models", package: "<Domain>-Self"),
                .product(name: "<Domain>ReluxInt", package: "<Domain>-Self"),
                .product(name: "<Domain>ServiceInt", package: "<Domain>-Self"),
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

## Dynamic Linking Guardrails

SwiftPM/Xcode quirks require careful handling:

1. **Use product dependencies** (not target deps) inside the same package
2. **Self-reference trick**: Declare `.package(name: "<Domain>-Self", path: ".")` and reference products via that package to force dynamic linkage
3. **All products `type: .dynamic`** except TestSupport
4. **App/test targets must link AND embed** all dynamic products

If SwiftPM behavior regresses, fallback: split into two packages (`<Domain>Interfaces` and `<Domain>Implementations`).

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
| SwiftPM dynamic-in-one-package is brittle | Fallback: split into Interface/Implementation packages |
| Verbose imports | Optional facade product (`<Domain>Kit`) for simple consumers |
| 6 products per domain seems heavy | Start with HybridState in ReluxImpl; split when complexity grows |
