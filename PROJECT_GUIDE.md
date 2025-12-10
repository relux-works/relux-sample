# PROJECT_GUIDE.md

This file provides comprehensive guidance for human developers and AI agents working with the codebase.

---

## Project Overview

The project is a sample app semostrating the architecture patterns and other guidelines for working in **Relux paradigm** for iOS, macOS, other consumer Darwin operating systems rojects, and subsequently in UI independent manner. The strongest focus is on maintaining highly robust and granular modular architecture adhering to SOLID principles (on various levels: through domain to modular structure), stric separation of UI and Business logic, Service Oriented Architecture, async-first and concurrency safe code execution, all glued through a asynchronous state management library called **Darwin Relux (new name Swift Relux)**.  

### Key Technologies

- **Language:** Swift 6.0
- **Platforms:** iOS 13+, macOS 10+
- **Architecture:** Redux/Flux-like UDF (**Darwin Relux** (**Swift Relux**))
- **UI Framework:** SwiftUI, although business layer is completely UI independed. The latmust test that demostrates (and prooves while development is in progress) the separation of business logic is creation of CLI for key user scenarios tied to the same business logic as GUI framework.
- **Dependency Management:** Swift Package Manager (SPM) via local checkouts managed by `xcgen` (current sample project does not use xcgen and relies on vanilla Xcode project files)
// - **Project Generation:** `xcodegen` (via custom `xcgen` wrapper) // not in use now //

---

## Directory Structure

The project follows a modular monorepo-style structure:

`Fill and keep up to date the directory structure`

---

## Setup & Build

`to be explaned`

## Architecture


### Key Patterns

- **State mutations** go through Relux Actions/Reducers only; never mutate models in Views.
- **Side effects** defined in Sagas. Sagas are stateless unlesss service layer requires bi directional communication (e.g. websockets)
- Actions are defined on Container level in Ui layer (never in Views) and passed to views as callbacks wrapped into Relux.UI.ViewCallback struct which gurantees equtability and concurrency sendability.
- View Relux.UI.ViewCallback struct ,ust be stored in let callbacks constant.
- All Views must conform to Relux.UI.View protocol and implement the let Props constant, which holds structure conforming to Relux.UI.ViewProps protocol 

### SwiftUI View Decomposition

To minimize SwiftUI attribute graph invalidation and maintain clean separation between state management and presentation, we follow these principles:

#### Container/View Separation (ReluxUI)

- **Containers** (`Relux.UI.Container`): Bridge between Relux and UI layer
  - Access `@EnvironmentObject` for state and relays
  - **All Relux action dispatching MUST be defined here** - never in views
  - Extract and transform data for child views
  - Pass actions as callbacks to views
- **Views**: Pure presentation components
  - Know nothing about Relux, environment objects, or state management
  - **NEVER dispatch Relux actions directly** - only call callbacks
  - Receive only primitive data and callbacks
  - Fully testable in isolation without mocking Relux

#### Atomic Data Dependencies

- Pass only the specific values a view needs, not parent objects or state containers
- If a view needs `player.name`, pass `name: String`, not `player: Player`
- This prevents view invalidation in Attribute Graph when unrelated properties change

#### Struct Views Only

- Define all views as `struct` types, never as computed properties or functions
- Separate structs create identity boundaries in the attribute graph


#### Hierarchical Namespacing

- These helper View structs live inside parent view namespace and defined in private extension
- When several views of almost identical behavor emerge in different places, consider refactoring in shared component
- Nest child view structs within parent extensions for clear ownership
- Example: `UI.GameBoard.PlayerSetupView.HeaderSection`

#### Callbacks Over Bindings

- For actions: pass callbacks that dispatch Relux actions
- For editing: use local `@State` + dispatch on commit/blur
- Bindings couple child to parent's exact storage shape, avoid as mush as possible

**Example Structure:**

```swift
// Container: Knows about Relux, extracts data, dispatches actions
extension UI.GameBoard {
    struct Container: Relux.UI.Container {
        @EnvironmentObject private var state: GameBoardState
        @EnvironmentObject private var orientationRelay: OrientationRelay // ❗️this pattern not explained yet

        var body: some View {
            GameView(
                phase: state.phase,
                orientation: orientationRelay.value.orientation,
                onStart: startGame
            )
        }

        private func startGame() {
            Task { await actions { GameEffect.start } }
        }
    }
}

// View: Pure presentation, no Relux knowledge
extension UI.GameBoard {
    struct GameView: View {
        let phase: GamePhase
        let orientation: DeviceOrientation
        let onStart: () -> Void // ❗️rewrite to show Relux.UI.ViewCallbacks pattern

        var body: some View {
            VStack {
                HeaderSection(orientation: orientation)
                FooterSection(onStart: onStart)
            }
        }
    }
}

// Child views: Atomic data only, nested in parent namespace
extension UI.GameBoard.GameView {
    struct HeaderSection: View {
        let orientation: DeviceOrientation
        var body: some View { Text("Orientation: \(orientation.rawValue)") }
    }

    struct FooterSection: View {
        let onStart: () -> Void
        var body: some View { Button("Start", action: onStart) }
    }
}
```

---

## Key Files

`fill and keep up to date reference to key files in the project such as entry points, important logic, etc.`

---

## Testing

The project uses the **Swift Testing** framework (macros like `@Suite`, `@Test`, `#expect`, `#require`). Prefer these over XCTest APIs.

### Test Target Types


**Hostless vs Hosted:**

- **Hostless tests** run without launching the app. Use for pure logic in Swift Packages.
- **Hosted tests** run inside the app process via `TEST_HOST`/`BUNDLE_LOADER`.

Fe keep focus on modular architecture, as such all tests must live in dedicated swift packages tests targets.

### Test Naming Conventions

- Name suites after behavior (e.g., `FeatureScorerTests`).
- Name test methods as readable sentences (e.g., `scoresClosedForest`).

### Isolated State Management (Relux)

Test Sagas and Reducer in isolation

// fill samples //

### Running Tests

**Xcode:**

1. Select app scheme
2. Product → Test (Cmd+U)

All tests from the test plan run together. // implement test plan

**CLI:**

```bash
# Build only (quiet mode - shows only warnings/errors)
xcodebuild build \
  -project Proejct.xcodeproj \
  -scheme app-scheme \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  2>&1 | xcbeautify --quiet

# Run all tests via test plan
xcodebuild test \
  -project Proejct.xcodeproj \
  -scheme app-scheme \
  -testPlan TestPlanName \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  2>&1 | xcbeautify

# Run package tests directly
```

**Note:** Use `xcbeautify --quiet` for builds to minimize output (only warnings/errors). For tests, use regular `xcbeautify` to see test names and results. 
**Important:** Always include `2>&1` before the pipe to capture stderr. Avoid complex shell variable assignments (e.g., `log=/tmp/x.log; cmd | tee "$log"`) as they behave inconsistently across shells.
// todo: we must define robust pattern and toolchain to optimize agentic context usage from outputs like these.

### Adding a New Swift Package Module

// todo: instructions for adding module


## Coding Style & Naming Conventions

- Swift 6, 4-space indent, line length ≈ 120.
- Follow Swift API Design Guidelines: PascalCase types, lowerCamelCase members, verbs for functions.
- Favor value semantics and pure reducers/sagas (Relux UDF). Keep side effects inside actions/sagas, not reducers. Sagas communicate with Services for side-effect logic. Services communicate with data providers and connection sockets etc. Service layer must be defined is dedicated module.
- `@MainActor` for UI/state-touching async code.

## Version Control & Commit Conventions

We follow the **Standard Imperative Git Style**. This ensures the project history reads like a distinct changelog and matches the built-in conventions of Git tools.

### The Imperative Mood

The subject line (first line) must be phrased as a command. To verify the format, the message must grammatically complete the sentence:

> "If applied, this commit will **[Your Subject Line]**"

| Example | Status |
|---------|--------|
| `Refactor topology manager to support dual-layer rivers` | ✅ Good |
| `Refactored topology manager` | ❌ Bad (Past tense) |
| `Refactoring topology manager` | ❌ Bad (Continuous/Progressive) |

### Commit Style

To ensure readability in both CLI (`git log --oneline`) and GUI clients, strict separation between the summary and details is required.

- **Subject (Line 1):** Concise summary, under 50 characters ideal (max 72). No trailing period.
- **Blank Line (Line 2):** Mandatory. Separates header from body.
- **Body (Line 3+):** Detailed explanation. Focus on **why** the change was made, not just *how* (the code shows *how*). Wrap text at approx. 72 characters. Commits are used to gain contenxt on previos development achienvemnts and challedges and thus commit message must fit important context in there. 
- **Grouping:** Group related edits per commit; do not bundle unrelated content updates.
- **Content Rule:** Commit messages must **only** describe the work done. Do not include authorship references, co-authorship references, tool attribution, or any other information unrelated to the actual changes and developemnt context.

### What NOT to Commit

- Anything unrelated to work done such as authorship, credentials of authors, etc.
- Generated artifacts (`.build/`, `.packages/`, derived data, regenerated `.xcodeproj`)
- Secrets in plist/entitlement files; use user-specific xcconfig overrides instead. If you act as autonomous agent and about to commit confidential information, abort immidiately and inform user.
