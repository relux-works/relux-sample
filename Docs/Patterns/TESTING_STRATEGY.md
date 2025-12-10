# Testing Strategy

How to test business logic through discrete, isolated layers.

---

## Philosophy

Test each layer in isolation. Combined, they cover the entire business logic without integration test complexity.
```
┌─────────────────────────────────────────────────────────────────┐
│                        Business Logic                           │
└─────────────────────────────────────────────────────────────────┘
                              │
     ┌────────────┬───────────┼───────────┬────────────┐
     ▼            ▼           ▼           ▼            ▼
┌─────────┐ ┌─────────┐ ┌───────────┐ ┌─────────┐ ┌─────────┐
│  Saga   │ │ Reducer │ │  Service  │ │Orchestr.│ │  Smoke  │
│  Tests  │ │  Tests  │ │   Tests   │ │  Tests  │ │  Tests  │
└─────────┘ └─────────┘ └───────────┘ └─────────┘ └─────────┘
     │            │           │           │            │
     ▼            ▼           ▼           ▼            ▼
 Service      State        Data      Cross-domain   Wiring
  calls      mutations   transforms  coordination  validation
```

---

## Five Testing Layers

### 1. Saga/Flow Tests

**What**: Verify orchestration logic — service calls, action dispatching, error handling.

**Mock**: Service  
**Assert**: Dispatched actions/effects via Logger
```swift
@Test
func obtainNotes_success_dispatchesAction() async {
    // Arrange
    let logger = Relux.Testing.Logger()
    let dispatcher = Relux.Dispatcher(logger: logger)
    let service = Notes.Business.ServiceMock()
    let flow = await Notes.Business.Flow(dispatcher: dispatcher, svc: service)
    
    let notes: [Notes.Business.Model.Note] = .stub
    service.stubObtainSuccess(notes)
    
    // Act
    _ = await flow.apply(Notes.Business.Effect.obtainNotes)
    
    // Assert
    #expect(service.obtainCallCount == 1)
    #expect(logger.findNotesAction(.obtainSuccess(noteCount: notes.count)) != nil)
}

@Test
func obtainNotes_failure_dispatchesErrorTracking() async {
    // Arrange
    let logger = Relux.Testing.Logger()
    let dispatcher = Relux.Dispatcher(logger: logger)
    let service = Notes.Business.ServiceMock()
    let flow = await Notes.Business.Flow(dispatcher: dispatcher, svc: service)
    
    let err = Notes.Business.Err.obtainFailed(cause: StubError())
    service.stubObtainFailure(err)
    
    // Act
    _ = await flow.apply(Notes.Business.Effect.obtainNotes)
    
    // Assert
    #expect(logger.findNotesAction(.obtainFail(errorMessage: err.localizedDescription)) != nil)
    #expect(logger.findEffect(ErrorHandling.Business.Effect.self) { 
        if case .track = $0 { return true }
        return false
    } != nil)
}
```

**Covers**:
- Correct service method called
- Correct action dispatched on success
- Correct action dispatched on failure
- Error tracking triggered
- Flow returns correct result

---

### 2. Reducer/State Tests

**What**: Verify state mutations — actions correctly update state.

**Mock**: None — test state directly  
**Assert**: State values after action

**Important**: Use exhaustive `switch` (no `default`) so compiler catches unhandled actions.
```swift
// In reducer — compiler enforces all cases handled
func reduce(with action: Notes.Business.Action) async {
    switch action {  // No 'default' clause
        case .obtainNotesSuccess(let notes): ...
        case .obtainNotesFail(let err): ...
        case .upsertNoteSuccess(let note): ...
        // Compiler errors if new case added but not handled
    }
}
```
```swift
@Test
func obtainNotesSuccess_updatesState() async {
    // Arrange
    let state = Notes.Business.State()
    let notes: [Notes.Business.Model.Note] = .stub
    
    // Act
    await state.reduce(with: Notes.Business.Action.obtainNotesSuccess(notes: notes))
    
    // Assert
    #expect(await state.notes == .success(notes))
}

@Test
func deleteNoteSuccess_removesFromState() async {
    // Arrange
    let state = Notes.Business.State()
    let notes: [Notes.Business.Model.Note] = .stub
    let noteToDelete = notes.first!
    
    await state.reduce(with: Notes.Business.Action.obtainNotesSuccess(notes: notes))
    
    // Act
    await state.reduce(with: Notes.Business.Action.deleteNoteSuccess(note: noteToDelete))
    
    // Assert
    let currentNotes = await state.notes.value
    #expect(currentNotes?.contains(noteToDelete) == false)
    #expect(currentNotes?.count == notes.count - 1)
}

@Test
func cleanup_resetsState() async {
    // Arrange
    let state = Notes.Business.State()
    await state.reduce(with: Notes.Business.Action.obtainNotesSuccess(notes: .stub))
    
    // Act
    await state.cleanup()
    
    // Assert
    guard case .initial = await state.notes else {
        Issue.record("Expected initial state")
        return
    }
}
```

**Covers**:
- Success actions update state correctly
- Failure actions update state correctly
- Upsert adds/updates items
- Delete removes items
- Cleanup resets to initial

---

### 3. Service Tests

**What**: Verify data layer — API calls, DTO transformations, error mapping.

**Mock**: Fetcher / API client  
**Assert**: Correct calls made, correct transformations applied
```swift
@Test
func getNotes_transformsDTOToModel() async {
    // Arrange
    let fetcher = Notes.Data.Api.FetcherMock()
    let service = Notes.Business.Service(fetcher: fetcher)
    
    let dto = Notes.Data.Api.DTO.Note(
        id: UUID(),
        date: .now,
        title: "Test",
        content: "Content"
    )
    fetcher.stubGetNotesSuccess([dto])
    
    // Act
    let result = await service.getNotes()
    
    // Assert
    guard case .success(let notes) = result else {
        Issue.record("Expected success")
        return
    }
    #expect(notes.count == 1)
    #expect(notes.first?.id == dto.id)
    #expect(notes.first?.title == dto.title)
}

@Test
func getNotes_mapsError() async {
    // Arrange
    let fetcher = Notes.Data.Api.FetcherMock()
    let service = Notes.Business.Service(fetcher: fetcher)
    
    fetcher.stubGetNotesFailure(.networkError)
    
    // Act
    let result = await service.getNotes()
    
    // Assert
    guard case .failure(let err) = result else {
        Issue.record("Expected failure")
        return
    }
    #expect(err == .obtainFailed(cause: .networkError))
}
```

**Covers**:
- DTO → Model transformation
- Model → DTO transformation
- Error mapping
- Correct API methods called
- Sorting/filtering logic

**When to test Fetcher separately**: If Fetcher has complex logic (retry, caching, pagination), add dedicated tests with mocked URLSession.

---

### 4. Orchestrator Tests

**What**: Verify cross-domain coordination — correct effects dispatched to other domains.

**Mock**: None — orchestrators only dispatch, don't call services  
**Assert**: Cross-domain effects dispatched via Logger
```swift
@Test
func authLogout_triggersProfileAndSettingsClear() async {
    // Arrange
    let logger = Relux.Testing.Logger()
    let dispatcher = Relux.Dispatcher(logger: logger)
    let saga = SessionOrchestration.Saga(dispatcher: dispatcher)
    
    // Act
    await saga.apply(Auth.Business.Effect.runLogoutFlow)
    
    // Assert — verify ALL expected dispatches
    #expect(logger.findEffect(Profile.Business.Effect.self) { 
        if case .clearProfile = $0 { return true }
        return false
    } != nil)
    
    #expect(logger.findEffect(Settings.Business.Effect.self) { 
        if case .resetToDefaults = $0 { return true }
        return false
    } != nil)
}

@Test
func authSuccess_triggersProfileFetch() async {
    // Arrange
    let logger = Relux.Testing.Logger()
    let dispatcher = Relux.Dispatcher(logger: logger)
    let saga = SessionOrchestration.Saga(dispatcher: dispatcher)
    
    // Act
    await saga.apply(Auth.Business.Effect.authSucceeded(userId: "user-123"))
    
    // Assert
    #expect(logger.findEffect(Profile.Business.Effect.self) { 
        if case .fetchProfile(let id) = $0 { return id == "user-123" }
        return false
    } != nil)
}
```

**Covers**:
- Correct domains notified on events
- Correct parameters passed
- Concurrent dispatches all fire

---

### 5. Smoke Tests (Optional)

**What**: Lightweight integration tests verifying wiring between layers.

**Mock**: Service only (lowest layer)  
**Assert**: End state after full flow

Catches contract gaps where saga dispatches action that reducer doesn't handle.
```swift
@Test
func fullObtainFlow_stateUpdates() async {
    // Real state + real flow, mock service only
    let state = Notes.Business.State()
    let service = Notes.Business.ServiceMock()
    let store = Relux.Store()
    await store.register(state)
    
    let flow = Notes.Business.Flow(svc: service, store: store)
    await store.register(saga: flow)
    
    let notes: [Notes.Business.Model.Note] = .stub(count: 3)
    service.stubObtainSuccess(notes)
    
    // Act
    await store.dispatch(Notes.Business.Effect.obtainNotes)
    
    // Assert
    #expect(await state.notes.value?.count == 3)
}
```

**When to write smoke tests**:
- Critical user flows (login, checkout, data sync)
- After fixing wiring bugs
- Not needed for every feature

---

## UIState Testing

### Test Transformations as Pure Functions

Extract transformation logic as static functions — enables synchronous, deterministic tests.
```swift
// In UIState — extract as static
extension Notes.UI.State {
    static func groupByDay(_ notes: [Note]) -> [[Note]] {
        notes
            .sorted { $0.createdAt > $1.createdAt }
            .chunked { $0.createdAt.startOfDay == $1.createdAt.startOfDay }
            .map { Array($0) }
    }
}

// Test — synchronous, no timing issues
@Test
func groupByDay_groupsCorrectly() {
    let today = Date.now
    let yesterday = today.addingTimeInterval(-86400)
    let notes: [Notes.Business.Model.Note] = [
        .stub(createdAt: today),
        .stub(createdAt: today),
        .stub(createdAt: yesterday),
    ]
    
    let grouped = Notes.UI.State.groupByDay(notes)
    
    #expect(grouped.count == 2)
    #expect(grouped[0].count == 2)  // today
    #expect(grouped[1].count == 1)  // yesterday
}
```

### Pipeline Wiring Test (Minimal)

One test to verify Combine pipeline is connected:
```swift
@Test
func pipeline_propagatesChanges() async throws {
    let businessState = Notes.Business.State()
    let uiState = await Notes.UI.State(state: businessState)
    
    await businessState.reduce(with: .obtainNotesSuccess(notes: .stub(count: 2)))
    
    try await withTimeout(seconds: 1.0) {
        guard let grouped = try await uiState.$notesGroupedByDay.asyncStream.next()?.value else {
            Issue.record("Pipeline did not emit")
            return
        }
        #expect(grouped.flatMap { $0 }.count == 2)
    }
}
```

---

## Concurrent Dispatch Assertions

When saga dispatches `.concurrently`, assert **all** expected dispatches:
```swift
// Saga code
await actions(.concurrently) {
    Notes.Business.Action.upsertNoteFail(err: err)
    ErrorHandling.Business.Effect.track(error: err)
}

// Test — verify both
@Test
func upsertFailure_dispatchesActionAndTracking() async {
    // ... setup ...
    
    // Assert both were dispatched
    #expect(logger.findNotesAction(.upsertFail(...)) != nil)
    #expect(logger.findEffect(ErrorHandling.Business.Effect.self) { ... } != nil)
    
    // Optionally verify counts
    #expect(logger.countActions(Notes.Business.Action.self) == 1)
    #expect(logger.countEffects(ErrorHandling.Business.Effect.self) == 1)
}
```

---

## Test Data Guidelines

### Random vs Explicit Values

**Random** — when value doesn't matter for assertion:
```swift
let note = Note.stub()  // Random title/content fine
#expect(service.upsertCallCount == 1)  // Asserting call, not content
```

**Explicit** — when asserting specific values:
```swift
let note = Note.stub(title: "Expected Title")  // Explicit
#expect(capturedNote.title == "Expected Title")  // Asserting content
```

### Deterministic IDs for Assertions
```swift
let id = UUID()
let note = Note.stub(id: id)

// Later...
#expect(logger.findNotesAction(.deleteSuccess(noteId: id)) != nil)
```

---

## Edge Cases Checklist

Test these scenarios for each domain:

| Case | Example |
|------|---------|
| Empty collection | `obtainNotes` returns `[]` |
| Single item | Delete the only note |
| Duplicate handling | Upsert note with existing ID |
| Not found | Delete non-existent note |
| Concurrent modifications | Two upserts for same note |
| Cleanup mid-operation | Logout while fetching |
| Pagination boundary | Fetch page 2 when only 1 page exists |
| Invalid input | Empty title, nil values |

---

## Coverage Matrix

| Layer | Input | Mock | Asserts | Catches |
|-------|-------|------|---------|---------|
| Saga/Flow | Effect | Service | Actions/effects dispatched | Orchestration bugs |
| Reducer | Action | None | State values | Mutation bugs |
| Service | Method | Fetcher | Transformations, calls | Mapping bugs |
| Orchestrator | Effect | None | Cross-domain effects | Coordination bugs |
| UIState | N/A | None | Transformation output | Aggregation bugs |
| Smoke | Effect | Service | End state | Wiring bugs |

---

## Test File Organization
```
<Domain>Tests/
  Business/
    Saga/
      <Domain>Tests+Saga+Obtain.swift
      <Domain>Tests+Saga+Upsert.swift
      <Domain>Tests+Saga+Delete.swift
    State/
      <Domain>Tests+State+Initial.swift
      <Domain>Tests+State+Obtain.swift
      <Domain>Tests+State+Upsert.swift
      <Domain>Tests+State+Delete.swift
    Service/
      <Domain>Tests+Service+Obtain.swift
      <Domain>Tests+Service+Upsert.swift
  UI/
    State/
      <Domain>Tests+UIState+Transformations.swift
      <Domain>Tests+UIState+Pipeline.swift
  Smoke/
      <Domain>Tests+Smoke+CriticalFlows.swift

<Concern>OrchestrationTests/
  <Concern>OrchestrationTests+Auth.swift
  <Concern>OrchestrationTests+Profile.swift
```

---

## What NOT to Unit Test

| Skip | Reason |
|------|--------|
| SwiftUI Views | Use previews + manual testing |
| Containers | Thin glue layer, test via UI tests if needed |
| IoC wiring | Caught by app launch |
| Navigation routing | Caught by UI tests |
| Fetcher (usually) | Unless complex logic — test via Service tests |

---

## Checklist: New Feature

1. [ ] Saga/Flow tests — all effect cases (success + failure)
2. [ ] Reducer tests — all action cases, exhaustive switch
3. [ ] Service tests — transformations, error mapping
4. [ ] Orchestrator tests — if cross-domain coordination involved
5. [ ] UIState tests — transformation logic as pure functions
6. [ ] Edge cases — empty, single, duplicate, concurrent
7. [ ] Smoke test — for critical user flows only
