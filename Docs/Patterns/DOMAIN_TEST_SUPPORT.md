# Domain Test Support

Per-domain test utilities built on TestInfrastructure.

---

## Purpose

Each domain provides `<Domain>TestSupport` product containing:
- Service mock with call tracking and handlers
- Router mock (if domain navigates)
- Model stub factories
- Testable wrappers for actions/effects

---

## Location
```
Packages/<Domain>/Sources/<Domain>TestSupport/
```

---

## Structure
```
<Domain>TestSupport/
  Mocks/
    <Domain>+ServiceMock.swift
    <Domain>+RouterMock.swift      (if needed)
  Stubs/
    <Domain>+Model+Stubs.swift
  Assertions/
    <Domain>+Action+Testable.swift
    <Domain>+Effect+Testable.swift
    <Domain>+LoggerExtensions.swift
```

---

## Package.swift
```swift
.target(
    name: "<Domain>TestSupport",
    dependencies: [
        .product(name: "<Domain>Models", package: "<Domain>-Self"),
        .product(name: "<Domain>ReluxInt", package: "<Domain>-Self"),
        .product(name: "<Domain>ServiceInt", package: "<Domain>-Self"),
        .product(name: "TestInfrastructure", package: "TestInfrastructure"),
    ]
),
```

---

## Service Mock Pattern
```swift
public final class ServiceMock: IService, @unchecked Sendable {
    // Call counts
    public private(set) var obtainCallCount = 0
    
    // Captured arguments
    public private(set) var capturedNotes: [Model.Note] = []
    
    // Handlers — set in test
    public var obtainHandler: (() async -> Result<[Model.Note], Err>)?
    
    // Convenience stubs
    public func stubObtainSuccess(_ notes: [Model.Note]) {
        obtainHandler = { .success(notes) }
    }
}
```

---

## Model Stubs Pattern
```swift
extension <Domain>.Business.Model.Note {
    public static func stub(
        id: Id = .init(),
        title: String? = nil
    ) -> Self {
        .init(id: id, title: title ?? "Title \(Int.random(in: 1...1000))")
    }
}

extension Array where Element == <Domain>.Business.Model.Note {
    public static func stub(count: Int = 3) -> Self {
        (0..<count).map { _ in .stub() }
    }
}
```

---

## Testable Wrappers Pattern

For actions/effects with non-Equatable fields (like `Error`):
```swift
extension <Domain>.Business.Action {
    public enum Testable: Equatable {
        case obtainSuccess(noteCount: Int)
        case obtainFail(errorMessage: String)
    }
    
    public var testable: Testable {
        switch self {
        case .obtainNotesSuccess(let notes): .obtainSuccess(noteCount: notes.count)
        case .obtainNotesFail(let err): .obtainFail(errorMessage: err.localizedDescription)
        }
    }
}
```

---

## Logger Extensions Pattern
```swift
extension Relux.Testing.Logger {
    public func find<Domain>Action(_ testable: <Domain>.Business.Action.Testable) -> <Domain>.Business.Action? {
        findAction(<Domain>.Business.Action.self) { $0.testable == testable }
    }
}
```

---

## Usage
```swift
import Testing
import TestInfrastructure
import NotesTestSupport

@Test
func obtainNotes_success() async {
    // Arrange
    let logger = Relux.Testing.Logger()
    let service = Notes.Business.ServiceMock()
    service.stubObtainSuccess(.stub(count: 5))
    
    let flow = await Notes.Business.Flow(dispatcher: .init(logger: logger), svc: service)
    
    // Act
    _ = await flow.apply(Notes.Business.Effect.obtainNotes)
    
    // Assert
    #expect(service.obtainCallCount == 1)
    #expect(logger.findNotesAction(.obtainSuccess(noteCount: 5)) != nil)
}
```

---

## Checklist

1. [ ] Add `<Domain>TestSupport` target to Package.swift
2. [ ] Implement ServiceMock with handlers and call tracking
3. [ ] Add model stub factories
4. [ ] Add Testable wrappers if actions contain Error/non-Equatable
5. [ ] Add Logger extensions for domain-specific lookups
