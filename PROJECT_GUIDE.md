# PROJECT_GUIDE.md

Entry point for developers and AI agents working with this codebase.

---

## Quick Start

1. Read this file for project overview and conventions
2. Read pattern docs in `docs/Patterns/` for architecture decisions
3. Check `README.md` for setup and running instructions

---

## Project Overview

Sample app demonstrating architecture patterns and guidelines for working in **Relux paradigm** for iOS, macOS, and other Darwin platforms. UI-independent business layer design.

**Core focus areas:**
- Granular modular architecture adhering to SOLID principles
- Strict separation of UI and Business logic
- Service-oriented architecture
- Async-first, concurrency-safe code (Swift 6)
- Unidirectional data flow via **Darwin Relux** (Swift Relux)

The ultimate test demonstrating separation: CLI for key user scenarios tied to the same business logic as GUI.

---

## Tech Stack

| Component | Technology |
|-----------|------------|
| Language | Swift 6.0 |
| Platforms | iOS 17+, macOS 14+ |
| Architecture | Redux/Flux-like UDF (Darwin Relux) |
| UI | SwiftUI (business layer is UI-independent) |
| DI | SwiftIoC (async-first) |
| Dependencies | Swift Package Manager |

---

## Architecture Patterns

Detailed documentation in `docs/Patterns/`:

| Pattern | Document | Purpose |
|---------|----------|---------|
| Modular Architecture | [MODULAR_ARCHITECTURE.md](./docs/Patterns/MODULAR_ARCHITECTURE.md) | Domain decomposition into 6 dynamic products |
| Orchestration | [ORCHESTRATION.md](./docs/Patterns/ORCHESTRATION.md) | Cross-domain coordination without coupling |
| Flow vs Saga | [FLOW_VS_SAGA.md](./docs/Patterns/FLOW_VS_SAGA.md) | When operations return results vs fire-and-forget |
| Testing Strategy | [TESTING_STRATEGY.md](./docs/Patterns/TESTING_STRATEGY.md) | Discrete layer testing approach |
| Test Infrastructure | [TEST_INFRASTRUCTURE.md](./docs/Patterns/TEST_INFRASTRUCTURE.md) | Shared test utilities |
| Domain Test Support | [DOMAIN_TEST_SUPPORT.md](./docs/Patterns/DOMAIN_TEST_SUPPORT.md) | Per-domain mocks and stubs |

---

## Directory Structure
```
Packages/
  Auth/                       ← Domain package (6 products)
  AuthUI/                     ← UI package (2 products)
  SessionOrchestration/       ← Cross-domain coordinator
  DataOrchestration/          ← Cross-domain coordinator
  TestInfrastructure/         ← Shared test utilities

relux_sample/
  Modules/                    ← App-level modules (not yet extracted)
    App/                      ← Root app module
    Auth/                     ← Auth (to be extracted)
    Notes/                    ← Notes domain
    Navigation/               ← Navigation state
    Account/                  ← Account UI
    ErrorHandling/            ← Error tracking
    Logger/                   ← Relux logger
  Adapters/                   ← Domain router adapters
  Utils/                      ← Shared utilities
  IoC/                        ← Dependency registration

relux_sampleTests/            ← Test targets

Docs/
  Patterns/                   ← Architecture pattern docs
```

---

## Key Principles

### Dependency Direction
```
UI Layer (SwiftUI Views/Containers)
    │
    ▼ depends on
Domain Interfaces (*ReluxInt, *ServiceInt)
    │
    ▼ implemented by
Domain Implementations (*ReluxImpl, *ServiceImpl)
    │
    ▼ depends on
Domain Models (*Models)
```

### State Management

- **BusinessState**: Actor-isolated, owns domain truth
- **UIState**: MainActor-isolated, aggregates for UI consumption
- **HybridState**: Combined approach for simpler domains

### Side Effects

- **Flow**: Returns `Result` — use when caller needs outcome
- **Saga**: Returns `Void` — fire-and-forget side effects
- **Orchestrator**: Cross-domain Saga — coordinates between domains

### Core Rules

- **State mutations** go through Relux Actions/Reducers only; never mutate models in Views
- **Side effects** defined in Sagas; Sagas are stateless unless service layer requires bidirectional communication (e.g., websockets)
- **Actions** defined on Container level in UI layer (never in Views) and passed to views as callbacks wrapped into `Relux.UI.ViewCallback`
- **Views** must conform to `Relux.UI.View` protocol and implement `let props` constant with structure conforming to `Relux.UI.ViewProps`
- **Sagas** communicate with Services for side-effect logic; Services communicate with data providers

---

## SwiftUI View Decomposition

To minimize SwiftUI attribute graph invalidation and maintain clean separation between state management and presentation.

### Container/View Separation (ReluxUI)

**Containers** (`Relux.UI.Container`): Bridge between Relux and UI layer
- Access `@EnvironmentObject` for state
- **All Relux action dispatching MUST be defined here** — never in views
- Extract and transform data for child views
- Pass actions as callbacks to views

**Views** (`Relux.UI.View`): Pure presentation components
- Know nothing about Relux, environment objects, or state management
- **NEVER dispatch Relux actions directly** — only call callbacks
- Receive only primitive data and callbacks via `Props` and `Actions`
- Fully testable in isolation without mocking Relux

### Atomic Data Dependencies

- Pass only the specific values a view needs, not parent objects
- If a view needs `player.name`, pass `name: String`, not `player: Player`
- Prevents view invalidation when unrelated properties change

### Struct Views Only

- Define all views as `struct` types, never as computed properties or functions
- Separate structs create identity boundaries in the attribute graph

### Hierarchical Namespacing

- Helper View structs live inside parent view namespace in private extension
- When similar views emerge in different places, refactor to shared component
- Example: `Notes.UI.List.Container.Page.NoteRow`

### Callbacks Over Bindings

- For actions: pass callbacks that dispatch Relux actions
- For editing: use local `@State` + dispatch on commit/blur
- Bindings couple child to parent's exact storage shape — avoid when possible

### Example Structure
```swift
// Container: Knows about Relux, extracts data, dispatches actions
extension Notes.UI.List {
    struct Container: Relux.UI.Container {
        @EnvironmentObject private var state: Notes.UI.State

        var body: some View {
            Page(
                props: .init(notes: state.notesGroupedByDay),
                actions: .init(
                    onReload: ViewCallback(reloadNotes),
                    onCreate: ViewCallback(openCreate)
                )
            )
        }

        private func reloadNotes() async {
            await actions { Notes.Business.Effect.obtainNotes }
        }
        
        private func openCreate() async {
            await actions { AppRouter.Action.push(.app(page: .notes(.create))) }
        }
    }
}

// View: Pure presentation, no Relux knowledge
extension Notes.UI.List.Container {
    struct Page: Relux.UI.View {
        let props: Props
        let actions: Actions

        var body: some View {
            List {
                ForEach(props.notes) { note in
                    NoteRow(note: note)
                }
            }
            .refreshable(action: actions.onReload.callAsFunction)
        }
    }
}

// Props and Actions
extension Notes.UI.List.Container.Page {
    struct Props: Relux.UI.ViewProps {
        let notes: MaybeData<[[Note]], Err>
    }
    
    struct Actions: Relux.UI.ViewCallbacks {
        let onReload: ViewCallback<Void>
        let onCreate: ViewCallback<Void>
    }
}

// Child views: Atomic data only, nested in parent namespace
private extension Notes.UI.List.Container.Page {
    struct NoteRow: View {
        let note: Note
        var body: some View {
            VStack(alignment: .leading) {
                Text(note.title)
                Text(note.content).lineLimit(2)
            }
        }
    }
}
```

---

## Coding Style & Naming Conventions

### General

- Swift 6, 4-space indent, line length ≈ 120
- Follow Swift API Design Guidelines: PascalCase types, lowerCamelCase members
- Favor value semantics and pure reducers
- `@MainActor` for UI/state-touching async code

### File Naming
```
<Domain>+<Layer>+<Component>.swift

Examples:
  Auth+Business+State.swift
  Auth+Business+State+Reducer.swift
  Notes+UI+List+Container.swift
  Notes+UI+List+Container+Page.swift
  Notes+UI+List+Container+Page+Props.swift
```

### Namespace Structure
```swift
enum Notes {
    enum Data {
        enum Api {
            enum DTO {}
        }
    }
    enum Business {
        enum Model {}
    }
    enum UI {
        enum Model {}
        enum List {}
        enum Details {}
    }
}
```

---

## Testing

Framework: **Swift Testing** (`@Suite`, `@Test`, `#expect`, `#require`). Prefer over XCTest.

### Strategy

Test each layer in isolation — see [TESTING_STRATEGY.md](./docs/Patterns/TESTING_STRATEGY.md):

| Layer | Mock | Asserts |
|-------|------|---------|
| Saga/Flow | Service | Actions dispatched |
| Reducer | None | State values |
| Service | Fetcher | Transformations |
| Orchestrator | None | Cross-domain effects |

### Test Target Types

- **Hostless tests**: Run without app launch. Use for pure logic in packages.
- **Hosted tests**: Run inside app process. Use when app context needed.

All tests should live in dedicated Swift package test targets.

### Naming Conventions

- Name suites after behavior: `NotesFlowObtainTests`
- Name test methods as readable sentences: `obtainNotes_success_dispatchesAction`

### Running Tests

**Xcode**: Cmd+U

**CLI**:
```bash
# Build only
xcodebuild build \
  -project relux_sample.xcodeproj \
  -scheme relux_sample \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  2>&1 | xcbeautify --quiet

# Run tests
xcodebuild test \
  -project relux_sample.xcodeproj \
  -scheme relux_sample \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  2>&1 | xcbeautify
```

**Note**: Use `xcbeautify --quiet` for builds (only warnings/errors). Always include `2>&1` before pipe to capture stderr.

---

## Adding a New Domain

1. Create package following [MODULAR_ARCHITECTURE.md](Docs/Patterns/MODULAR_ARCHITECTURE.md)
2. Add `<Domain>TestSupport` product
3. Register module in `IoC.swift`
4. Add to relevant orchestrator if cross-domain coordination needed
5. Create UI package if domain has views

### Checklist

- [ ] `<Domain>Models` — namespace, data types, errors
- [ ] `<Domain>ServiceInt` — service protocol
- [ ] `<Domain>ServiceImpl` — concrete service
- [ ] `<Domain>ReluxInt` — actions, effects, state protocol
- [ ] `<Domain>ReluxImpl` — state, reducer, saga/flow, module
- [ ] `<Domain>TestSupport` — mocks, stubs
- [ ] Tests in `<Domain>Tests`
- [ ] Router adapter in app
- [ ] Module registration in IoC

---

## Version Control & Commit Conventions

**Standard Imperative Git Style** — history reads like a changelog.

### Imperative Mood

Subject line must complete: "If applied, this commit will **[subject]**"

| Example | Status |
|---------|--------|
| `Refactor topology manager to support dual-layer rivers` | ✅ Good |
| `Refactored topology manager` | ❌ Bad (past tense) |
| `Refactoring topology manager` | ❌ Bad (continuous) |

### Commit Format

- **Subject (Line 1)**: Under 50 chars ideal (max 72). No trailing period.
- **Blank Line (Line 2)**: Mandatory separator.
- **Body (Line 3+)**: Focus on **why**, not how. Wrap at ~72 chars.

### Rules

- Group related edits per commit; don't bundle unrelated changes
- Commit messages describe work done only — no authorship, tool attribution
- Never commit generated artifacts, secrets, or confidential information

### What NOT to Commit

- Authorship references, credentials
- Generated artifacts (`.build/`, derived data)
- Secrets in plist/entitlement files
- Regenerated `.xcodeproj` files

---

## Key Files

| File | Purpose |
|------|---------|
| `relux_sample/App.swift` | App entry point, Relux initialization |
| `relux_sample/IoC/IoC.swift` | Dependency registration |
| `relux_sample/Adapters/` | Domain router adapters |
| `Packages/Auth/` | Extracted Auth domain (reference implementation) |
| `docs/Patterns/` | Architecture pattern documentation |
