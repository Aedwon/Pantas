# Google sign-in exchange security audit

Scope: read-only inspection of commits `2ddad718d` and `38b2cea1c` against `3616560f9`, the supplied spec, and the email-code baseline. No builds, tests, or network calls were run.

### 1. medium: Anonymous UID rotation bypasses the exchange attempt limit

- File: `functions/src/googleSignIn.ts:113` (caller acceptance at line 50; limiter implementation in `functions/src/_limits.ts:12`).
- Scenario: A caller with valid fresh App Check tokens can create or rotate anonymous Firebase accounts and receive ten new exchange attempts for each UID. Each attempt can force an outbound tokeninfo request, even with an invalid Google token. There is no IP or global budget. This is an abuse/cost and availability weakness, not a demonstrated account takeover or App Check bypass. The implementation follows the spec's per-UID rule, but the email-code baseline explicitly recognizes this limitation and adds an IP limit to its request path (`functions/src/signInCode.ts`, `allowIp`).
- Fix: Retain the per-UID limiter and add a shared abuse budget, such as a keyed-hash IP limit and a global outbound-verification cap, before calling Google. Cover attempts across multiple anonymous UIDs in tests.

### 2. medium: A late exchange can switch an account after cancellation or an owner change

- File: `lib/core/auth/auth_repository.dart:249`–`253`.
- Scenario: Start the Google collision exchange, then dismiss the sign-in flow or change the Firebase user in another browser tab before the callable returns. The response unconditionally calls `_switchAccount`, which can sign out the new current user and install the earlier Google account. The local `_exclusive` queue does not prevent cross-tab auth changes, and `cancelVerification()` only increments an epoch that this path never checks. The accepted email-code path captures the initiating UID and epoch, supplies `valid`, and supplies `undoIfCancelled` (`auth_repository.dart:322`–`383`). This new path omits all three protections.
- Fix: Capture the initiating UID and identity epoch before the exchange. Reject stale results before switching and reuse the email-code validity checks after each awaited transition, including undoing a cancelled custom-token sign-in only when the installed identity is still the one this operation installed. Add delayed-response cancellation and cross-tab owner-change tests.

### 3. low: Direct popup collisions never reach the exchange

- File: `lib/core/auth/auth_repository.dart:223` (direct sign-in dispatch at line 232; generic catch at line 289).
- Scenario: With no current session, or with a nonanonymous session, `_signInWithLink` skips the anonymous-link catch and uses `googlePopup(link: false)` through `_switchAccount`. The gateway throws `GoogleAccountExistsException` for a collision on this branch too, but `_switchAccount` converts it directly into a failed result. It never exchanges the Google proof. The old session has already been signed out. The gateway test at `test/core/auth/google_existing_account_test.dart:263` explicitly covers this exception, but repository recovery is tested only for anonymous linking.
- Fix: Recover typed collisions from both popup branches. Ensure an authenticated caller exists for the exchange and preserve the owner/cancellation checks described above. Add repository coverage for a missing initial session and a nonanonymous account switch.

Review notes: No account-takeover path or App Check bypass was confirmed by static inspection. Audience, issuer, expiry, authoritative email domain, verified/disabled target checks, and conflicting Google-subject checks are present. The client requests limited-use App Check tokens, and the server rejects already-consumed tokens. Firestore rules prevent clients from resetting the Google rate-limit document. The changed client code carries the Google ID token only in local variables, a typed exception, and the callable request; no persistence or logging sink was found. The installed `firebase_auth_web` 6.2.6 preserves the error credential's ID token in `lib/src/utils/web_utils.dart:68`–`77`. Existing pending-credential handling and the sync/payment transition hooks remain in the call path. These are source-review observations, not runtime verification.

verdict: ship after fixes
