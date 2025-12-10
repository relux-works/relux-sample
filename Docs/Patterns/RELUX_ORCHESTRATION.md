# Relux Orchestration Pattern

Cross-domain coordination without coupling domains to each other.

---

## Problem

Domain A needs to react to Domain B's events, but:
- Domain A should not import Domain B
- Domain B should not know Domain A exists
- Bidirectional dependencies are forbidden

---

## Solution

Dedicated **Orchestrator** modules that:
- Import multiple domain interfaces (`*ReluxInt`)
- Listen to domain effects
- Dispatch cross-domain responses
- Own no state
- Return no results

---

## Structure
```
<Concern>Orchestration/
  Package.swift
  Sources/
    <Concern>OrchestrationImpl/
      <Concern>Orchestration+Saga.swift
      <Concern>Orchestration+Saga+<DomainA>.swift
      <Concern>Orchestration+Saga+<DomainB>.swift
      <Concern>Orchestration+Module.swift
      <Concern>Orchestration+Effect.swift    ← Optional
```

---

## Package.swift
```swift
// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "SessionOrchestration",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(
            name: "SessionOrchestration",
            type: .dynamic,
            targets: ["SessionOrchestrationImpl"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/ivalx1s/darwin-relux.git", from: "8.4.0"),
        // Domain interfaces ONLY
        .package(path: "../Auth"),
        .package(path: "../Profile"),
        .package(path: "../Settings"),
    ],
    targets: [
        .target(
            name: "SessionOrchestrationImpl",
            dependencies: [
                .product(name: "Relux", package: "darwin-relux"),
                .product(name: "AuthReluxInt", package: "Auth"),
                .product(name: "ProfileReluxInt", package: "Profile"),
                .product(name: "SettingsReluxInt", package: "Settings"),
            ]
        ),
    ]
)
```

---

## Saga Implementation

Main entry point routes to domain-specific handlers:

```swift
// SessionOrchestration+Saga.swift
import AuthReluxInt
import ProfileReluxInt
import SettingsReluxInt
import Relux

extension SessionOrchestration {
    public actor Saga: Relux.Saga {
        public init() {}
        
        public func apply(_ effect: any Relux.Effect) async {
            await handleAuthEffect(effect)
            await handleProfileEffect(effect)
            await handleSettingsEffect(effect)
        }
    }
}
```

Per-domain handlers in separate files:

```swift
// SessionOrchestration+Saga+Auth.swift
extension SessionOrchestration.Saga {
    func handleAuthEffect(_ effect: any Relux.Effect) async {
        switch effect as? Auth.Business.Effect {
            
        case .runLogoutFlow:
            await actions(.concurrently) {
                Profile.Business.Effect.clearProfile
                Settings.Business.Effect.resetToDefaults
            }
            
        case .authSucceeded(let userId):
            await actions {
                Profile.Business.Effect.fetchProfile(userId: userId)
            }
            
        default:
            break
        }
    }
}
```
```swift
// SessionOrchestration+Saga+Profile.swift
extension SessionOrchestration.Saga {
    func handleProfileEffect(_ effect: any Relux.Effect) async {
        switch effect as? Profile.Business.Effect {
            
        case .profileFetchFailed(let error) where error.isAuthError:
            await actions {
                Auth.Business.Effect.forceReauthentication
            }
            
        case .profileDeleted:
            await actions {
                Auth.Business.Effect.logout
            }
            
        default:
            break
        }
    }
}
```

---

## Module
```swift
// SessionOrchestration+Module.swift
import Relux

extension SessionOrchestration {
    public struct Module: Relux.Module {
        public let states: [any Relux.AnyState] = []  // Always empty
        public let sagas: [any Relux.Saga]
        
        public init() {
            self.sagas = [Saga()]
        }
    }
}
```

---

## Optional: Exposed Effects

If app/UI needs to trigger orchestrator directly:

```swift
// SessionOrchestration+Effect.swift
import Relux

extension SessionOrchestration {
    public enum Effect: Relux.Effect {
        case teardownSession
        case refreshSession
    }
}
```

Handle in saga:
```swift
extension SessionOrchestration.Saga {
    private func handleOwnEffect(_ effect: any Relux.Effect) async {
        switch effect as? SessionOrchestration.Effect {
        case .teardownSession:
            await actions(.concurrently) {
                Auth.Business.Effect.logout
                Profile.Business.Effect.clearProfile
            }
        default:
            break
        }
    }
}
```

---

## Granular Orchestrators

Prefer multiple focused orchestrators over one monolithic:

| Orchestrator | Domains | Responsibility |
|--------------|---------|----------------|
| `SessionOrchestration` | Auth, Profile, Settings | User session lifecycle |
| `DataOrchestration` | Auth, Notes, Files, Sync | User data coordination |
| `CommerceOrchestration` | Auth, Cart, Checkout, Payment | Purchase flows |

**Benefits**:
- Minimal import surface per orchestrator
- Clear ownership
- Parallel compilation
- Teams/agents can own specific orchestrators

---

## Key Constraints

| Rule | Rationale |
|------|-----------|
| No state | Orchestrators coordinate, domains own state |
| No result returns | Multiple downstream effects, no single result |
| Only `*ReluxInt` deps | Never import implementations |
| No orchestrator-to-orchestrator deps | Each listens independently |
| Register after domains | So orchestrator can listen to domain effects |

---

## Registration Order
```swift
// IoC.swift
await Relux.init(...)
    .register { @MainActor in
        // 1. Infrastructure
        resolve(ErrorHandling.Module.self)
        resolve(Navigation.Module.self)
        
        // 2. Domains
        resolve(Auth.Module.self)
        resolve(Profile.Module.self)
        await resolveAsync(Notes.Module.self)
        
        // 3. Orchestrators (last)
        resolve(SessionOrchestration.Module.self)
        resolve(DataOrchestration.Module.self)
    }
```

---

## Cross-Domain State Access

Orchestrators are stateless. When coordination needs domain state:

**UI Provides Context**

UI Container bundles necessary context into effect:
```swift
// Effect defines what context it needs
enum Effect: Relux.Effect {
    case sync(context: SyncContext)
    
    struct SyncContext: Sendable {
        let isAuthenticated: Bool
        let userId: String?
    }
}

// UI Container provides context
private func syncNotes() async {
    let context = Notes.Business.Effect.SyncContext(
        isAuthenticated: authState.isAuthenticated,
        userId: authState.userId
    )
    await actions { Notes.Business.Effect.sync(context: context) }
}
```

```

---

## Dependency Graph
```
┌─────────────────────────────────────────────────────────────────┐
│                        App Host Binary                          │
└─────────────────────────────────────────────────────────────────┘
                              │
      ┌───────────────────────┼───────────────────────┐
      ▼                       ▼                       ▼
┌───────────────┐   ┌───────────────────┐   ┌───────────────┐
│ Domain Impls  │   │   Orchestrators   │   │ Domain Impls  │
│               │   │                   │   │               │
│AuthReluxImpl  │   │SessionOrchestration│  │NotesReluxImpl │
│ProfileReluxImpl│  │  └ AuthReluxInt   │   │FilesReluxImpl │
│               │   │  └ ProfileReluxInt│   │               │
│               │   │  └ SettingsReluxInt│  │               │
│               │   │                   │   │               │
│               │   │DataOrchestration  │   │               │
│               │   │  └ AuthReluxInt   │   │               │
│               │   │  └ NotesReluxInt  │   │               │
│               │   │  └ FilesReluxInt  │   │               │
└───────────────┘   └───────────────────┘   └───────────────┘
        │                     │                     │
        ▼                     ▼                     ▼
┌───────────────────────────────────────────────────────────────┐
│                      Domain Interfaces                        │
│  AuthReluxInt, ProfileReluxInt, NotesReluxInt, FilesReluxInt │
└───────────────────────────────────────────────────────────────┘
```

---

## Checklist: New Orchestrator

1. [ ] Identify domains that need coordination
2. [ ] Create `<Concern>Orchestration/Package.swift`
3. [ ] Depend only on `*ReluxInt` products
4. [ ] Implement `Saga` with per-domain handler files
5. [ ] Implement `Module` with empty states
6. [ ] Register in app IoC after domain modules
7. [ ] Add tests
