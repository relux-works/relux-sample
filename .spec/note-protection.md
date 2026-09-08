# Notes access protection

The root is the Notes list. Settings is a native destination from its toolbar,
with Account and the existing architecture information. There is no global login,
logout, landing page or startup LocalAuthentication call.

Titles remain visible. Protecting a note immediately locks it. Unlock requests
system device-owner authentication for that note only; false, failure,
unavailability and cancellation fail closed. Unprotected notes need no auth.
Unlocked protected notes offer Relock and Remove Lock. Editing, deleting and
removing protection require access at the provider, regardless of UI state.

Auth exposes a reusable result-bearing Flow behind AuthReluxInt. Its service
creates a fresh LAContext for each evaluation and uses deviceOwnerAuthentication.
Notes receives an authentication closure at composition, without importing the
implementation or LocalAuthentication. Apple documents credential fallback at
https://developer.apple.com/documentation/localauthentication/lapolicy/deviceownerauthentication.

The in-memory provider owns protection metadata and transient per-note grants.
Upsert cannot replace metadata supplied by the provider. Locked read projections
contain empty bodies and lock status; search, details and editing use those
projections. Editor navigation carries only identity. Relock and background
invalidate pending authentication generations; inactive does not revoke access.
Versioned snapshots prevent late reads/actions from restoring older UI content.
Background immediately hides protected UI content and destroys editor drafts,
then dispatches provider revocation. Grants never persist across process restarts.

This is a sample access lock, not encryption or durable storage. Plaintext remains
in process memory. No persistence, network, custom password, or device navigation
is in scope. Verification uses focused Swift Testing and iOS compilation, with
narrowing mutants for refusal gates. Native system prompts and visual behavior
remain unverified by explicit request; no UI tests or screenshot work.
