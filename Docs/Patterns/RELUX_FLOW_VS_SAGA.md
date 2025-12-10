# Flow vs Saga

When to use `Relux.Flow` (returns result) vs `Relux.Saga` (fire-and-forget).

---

## Comparison

| Aspect | Flow | Saga |
|--------|------|------|
| Return type | `Relux.Flow.Result` | `Void` |
| Caller can await outcome | ✅ Yes | ❌ No |
| Use case | UI needs to react to success/failure | Fire-and-forget side effects |
| Service calls | ✅ Yes | ✅ Yes |
| State mutations | Via dispatched Actions | Via dispatched Actions |

---

## Flow

Use when **caller needs to know the outcome**.

```swift
// Definition
extension Notes.Business {
    actor Flow: Relux.Flow {
        private let svc: IService
        
        func apply(_ effect: any Relux.Effect) async -> Relux.Flow.Result {
            switch effect as? Notes.Business.Effect {
                case .upsert(let note): return await upsert(note)
                default: return .success
            }
        }
        
        private func upsert(_ note: Model.Note) async -> Relux.Flow.Result {
            switch await svc.upsert(note: note) {
                case .success:
                    await actions { Notes.Business.Action.upsertNoteSuccess(note: note) }
                    return .success
                case .failure(let err):
                    await actions { Notes.Business.Action.upsertNoteFail(err: err) }
                    return .failure(err)
            }
        }
    }
}
```
```swift
// Usage in UI
private func create(_ note: Note) async {
    switch await actions(actions: { Notes.Business.Effect.upsert(note: note) }) {
        case .success: 
            await close()  // Navigate away
        case .failure: 
            showError()    // Show error UI
    }
}
```

---

## Saga

Use for **fire-and-forget** side effects where UI observes state changes.

```swift
// Definition
extension Auth.Business {
    actor Saga: Relux.Saga {
        private let svc: IService
        
        func apply(_ effect: any Relux.Effect) async {
            switch effect as? Auth.Business.Effect {
                case .authorizeWithBiometry: await authorizeWithBiometry()
                default: break
            }
        }
        
        private func authorizeWithBiometry() async {
            switch await svc.runLocalAuth() {
                case .success:
                    await actions {
                        Auth.Business.Action.authSucceed
                        router.pushMain()
                    }
                case .failure(let err):
                    await actions {
                        Auth.Business.Action.authFailed(err: err)
                    }
            }
        }
    }
}
```

```swift
// Usage in UI — just dispatch, observe state for changes
private func tryLocalAuth() async {
    await actions { Auth.Business.Effect.authorizeWithBiometry }
    // UI updates via state observation, not return value
}
```

---

## Decision Guide

```
Does caller need to:
  - Navigate on success? → Flow
  - Show inline error? → Flow
  - Dismiss modal on completion? → Flow
  
Is the operation:
  - Background sync? → Saga
  - App lifecycle event? → Saga
  - Cross-domain coordination? → Saga (Orchestrator)
```

---

## Orchestrator: Always Saga

Orchestrators never return results because:

1. No single caller — they react to events
2. Multiple downstream effects — which result to return?
3. Domains handle their own success/failure


```swift
// Orchestrator Saga — always void
extension SessionOrchestration.Saga {
    func handleAuthEffect(_ effect: any Relux.Effect) async {
        switch effect as? Auth.Business.Effect {
            case .runLogoutFlow:
                // Fire-and-forget to multiple domains
                await actions(.concurrently) {
                    Profile.Business.Effect.clearProfile
                    Settings.Business.Effect.resetToDefaults
                }
            default: break
        }
    }
}
```

---

## Both in Same Domain

A domain can have both Flow and Saga:
```swift
extension Notes.Business {
    struct Module: Relux.Module {
        let sagas: [any Relux.Saga]
        
        init() {
            self.sagas = [
                Flow(svc: svc),      // CRUD operations — returns results
                BackgroundSaga()     // Sync, cleanup — fire-and-forget
            ]
        }
    }
}
```
