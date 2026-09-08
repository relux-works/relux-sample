# TASK-260909-1b1pyo: implement-notes-first-and-protection

## Description
Refactor app to open directly in Notes list without any startup authentication. Remove the Relux Sample landing screen and dead main/auth/logout entry routes. Move Account into a native Settings destination accessible from Notes toolbar. Repurpose existing Auth package as reusable system device-owner authentication for individual notes, not app-global login. Add per-note lock/unlock and explicit relock/remove-lock controls with simple native UI. Preserve iOS17/macOS14, glass availability fallbacks, KISS/DRY/SOLID and Relux dispatch-in-container, service/provider boundaries. Before behavioral refactors add focused Swift Testing coverage. No CUA, screenshots, simulator navigation, snapshot harnesses or UI tests: user explicitly requested blind best effort. Existing in-memory storage stays in-memory. Parent owns signed PR publication; leave candidate uncommitted for board handoff. Write a concise .spec/note-protection.md before implementation.

## Scope
(define task scope)

## Acceptance Criteria
Launch immediately shows Notes without system auth; Settings contains Account; old landing screen is removed. Locked note bodies are hidden from list/search/details/editor until that specific note is successfully authenticated using biometry or device credential fallback. Failed/false/cancelled/unavailable auth never grants access. Lock state survives refresh/edit in the in-memory provider; access is revoked on manual relock and app background, and late auth cannot regrant revoked access. Focused unit tests and iOS build pass; no deep UI testing
