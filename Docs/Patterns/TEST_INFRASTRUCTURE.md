# Test Infrastructure

Shared test utilities across all domain packages.

---

## Purpose

Centralized package providing domain-agnostic test utilities:
- Relux testing extensions
- Async test helpers
- Common mocks (API client, network, storage)
- Stub factories

---

## Location
```
Packages/TestInfrastructure/
```

---

## When to Add Here

✅ Add to TestInfrastructure:
- Utilities used by 2+ domains
- Domain-agnostic mocks (network, storage, keychain)
- Generic async/Combine test helpers
- Relux.Testing.Logger extensions

❌ Keep in DomainTestSupport:
- Domain-specific service mocks
- Domain model stubs
- Domain action/effect testable wrappers

---

## Key Components

| Component | Purpose |
|-----------|---------|
| `ReluxTestingExtensions` | `findAction`, `findEffect`, `assertDispatched` on Logger |
| `AsyncTestHelpers` | `withTimeout`, `waitUntil` |
| `CombineTestHelpers` | `Publisher.asyncStream` for testing pipelines |
| `APIClientMock` | Mock HTTP client with call tracking |
| `NetworkSessionMock` | Mock URLSession-like interface |
| `StorageMock` | Mock key-value storage |
| `StubError` | Generic error for testing failures |
| `JSONFixtures` | Load test fixtures from bundle |

---

## Usage
```swift
import Testing
import TestInfrastructure
import NotesTestSupport

@Test
func example() async throws {
    let logger = Relux.Testing.Logger()
    
    // ... trigger effect ...
    
    // Find action using TestInfrastructure extension
    let action = logger.findAction(Notes.Business.Action.self) { 
        if case .obtainNotesSuccess = $0 { return true }
        return false
    }
    #expect(action != nil)
    
    // Timeout helper
    try await withTimeout(seconds: 1.0) {
        // async work
    }
}
```

---

## Adding New Utilities

1. Confirm it's domain-agnostic
2. Add to appropriate folder (`Mocks/`, `Helpers/`, `Stubs/`)
3. Ensure thread-safety
4. Add brief doc comment with usage example
