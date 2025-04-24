# Relux SwiftUI Sample

[![Swift 6.0+](https://img.shields.io/badge/Swift-6.0+-red?logo=swift)](https://swift.org/download/)

A sample project showcasing the use of **Relux** — a Redux-inspired, async-first architecture written purely in Swift.

---

## Overview

Relux is a modern, asynchronous state management framework for Swift applications. It provides a predictable and structured data flow, simplifying the management of complex state changes. This sample project demonstrates how to use Relux to build a robust and scalable iOS application.

### Key Features
- **Unidirectional Data Flow**: Relux adopts a Redux-like architecture, ensuring state changes are predictable and manageable.
- **Async-First Design**: Built on Swift Concurrency, Relux enables safe and efficient asynchronous code.
- **Modular Architecture**: Organized into modules with distinct namespaces (e.g., `SampleApp.UI.Root`, `Auth.UI`, `Notes.UI`), this structure enhances scalability and aligns with Swift’s package and target isolation.

---

## Relux Architecture

### State Management in Relux

Relux provides three primary state types to address different needs: `BusinessState`, `UIState`, and `HybridState`.

#### Understanding the State Types
- **`BusinessState`**: Represents the core state of a module. It uses a reducer to handle actions and mutates the state directly for efficiency and compatibility with frameworks like SwiftUI.

    ```swift
    // Example of a BusinessState
    extension Notes.Business {
        actor State: Relux.BusinessState {
            @Published var notes: MaybeData<[Model.Note], Err> = .initial()

            func reduce(with action: any Relux.Action) async {
                // Handle actions and update state
            }

            func cleanup() async {
                // Clean up state when necessary
            }
        }
    }
    ```

- **`UIState`**: Manages the UI state by aggregating data from one or more `BusinessState` instances via subscriptions.

    ```swift
    // Example of a UIState
    extension Notes.UI {
        final class State: ObservableObject, Relux.UIState {
            @Published var notesGroupedByDay: MaybeData<[[Note]], Err> = .initial()
            @Published var notes: MaybeData<[Note.Id: Note], Err> = .initial()

            init(state: Notes.Business.State) async {
                // Initialize pipelines to aggregate data
            }
        }
    }
    ```

- **`HybridState`**: Combines features of `BusinessState` and `UIState`. Isolated to the main actor, it includes a reducer and is recommended as the starting point for most use cases. Separate into `BusinessState` and `UIState` as complexity increases.

    ```swift
    // Example of a HybridState
    extension Navigation.Business {
        @Observable
        final class ModalRouter: Relux.HybridState, BindableState {
            var modalSheet: Model.ModalPage?

            func reduce(with action: any Relux.Action) async {
                // Handle actions and update state
            }

            func cleanup() async {
                // Clean up state when necessary
            }
        }
    }
    ```

#### Key Considerations
- When using `BusinessState` and `UIState` separately, note that effects and actions may complete before state updates in reactive frameworks like Combine. Use appropriate observation techniques to monitor state changes.

---

### Actions and Effects

- **Actions**: Trigger state mutations through the reducer, serving as the sole mechanism for changing a module’s state.

    ```swift
    // Example of an Action
    extension Notes.Business {
        enum Action: Relux.Action {
            case obtainNotesSuccess(notes: [Model.Note])
            case obtainNotesFail(err: Err)
        }
    }
    ```

- **Effects**: Manage external interactions (e.g., API calls) and are handled by the module’s Saga, not the reducer.

    ```swift
    // Example of an Effect
    extension Notes.Business {
        enum Effect: Relux.Effect {
            case obtainNotes
            case upsert(note: Model.Note)
            case delete(note: Model.Note)
        }
    }
    ```

---

### Sagas

Sagas handle asynchronous side effects and business logic, improving modularity and testability.

```swift
// Example of a Saga
extension Notes.Business {
    actor Saga: Relux.Saga {
        private let svc: IService

        init(svc: IService) {
            self.svc = svc
        }

        func apply(_ effect: any Relux.Effect) async {
            // Handle effects and trigger actions
        }
    }
}
```

#### Benefits of Sagas
- **Business Logic Isolation**: Encapsulates logic for easier maintenance.
- **Testability**: Simplifies independent testing.
- **Service Layer Integration**: Integrates with a dedicated service layer for cleaner separation of concerns.

---

## Dependency Injection

The project leverages **SwiftIoC** for asynchronous dependency injection.

```swift
// Registering a module with SwiftIoC
ioc.register(Notes.Module.self, lifecycle: .container, resolver: { await Notes.Module() })
```

---

## Testing

Tests are provided for the Relux architecture and business logic.

```swift
// Example test for Notes.Business.Saga
@Test func obtainNotes_Success() async throws {
    // Arrange
    let reluxLogger = await Relux.Testing.MockModule<Action, Effect, SuccessPhantom>()
    await SampleApp.relux.register(reluxLogger)

    let service = NotesTests.Business.ServiceMock()
    let saga = Notes.Business.Saga(svc: service)

    // Act
    await saga.apply(Effect.obtainNotes)

    // Assert
    let successAction = await reluxLogger.getAction(Action.obtainNotesSuccess(notes: notes))
    #expect(successAction.isNotNil)
    #expect(service.obtainNotesCallCount == 1)

    // Teardown
    await SampleApp.relux.unregister(reluxLogger)
}
```

---

## License

Relux Sample is released under the MIT License.

---

## Authors

- Alexis Grigorev
- Artem Grishchenko
